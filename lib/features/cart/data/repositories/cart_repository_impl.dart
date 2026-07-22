import 'dart:convert';
import 'package:dio_complete/features/cart/data/datasources/cart_local_datasource.dart';
import 'package:dio_complete/features/cart/data/mappers/cart_item_mapper.dart';
import 'package:dio_complete/features/cart/domain/entities/cart_item.dart';
import 'package:dio_complete/features/cart/domain/repositories/cart_repository.dart';
import 'package:dio_complete/features/product/domain/entities/product.dart';

/// Repository giờ KHÔNG tự đụng vào Hive Box nữa - mọi lời đọc/ghi đi qua
/// [CartLocalDataSource]. Repository chỉ còn lo diễn giải dữ liệu thô (qua
/// CartItemMapper) và các thao tác nghiệp vụ (tăng/giảm số lượng, gộp khi
/// thêm trùng sản phẩm...).
class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource _dataSource;

  CartRepositoryImpl(this._dataSource);

  List<CartItem> _parseItems(List<dynamic> raw) {
    return raw
        .whereType<Map>()
        .map((e) => CartItemMapper.fromMap(Map<String, dynamic>.from(e)))
        .whereType<CartItem>()
        .toList();
  }

  @override
  List<CartItem> loadItems() {
    final raw = _dataSource.readItems();
    if (raw == null) return [];
    if (raw is List) return _parseItems(raw);

    // Bản ghi cũ có thể lưu dạng String JSON thay vì List trực tiếp.
    if (raw is String && raw.isNotEmpty) {
      final decoded = jsonDecode(raw);
      if (decoded is List) return _parseItems(decoded);
    }
    return [];
  }

  @override
  Future<void> addItem(Product product, {int quantity = 1}) async {
    final items = loadItems();
    final idx = items.indexWhere((e) => e.product.id == product.id);

    if (idx >= 0) {
      items[idx] = items[idx].copyWithQty(items[idx].quantity + quantity);
    } else {
      items.add(CartItem(product: product, quantity: quantity));
    }

    await _save(items);
  }

  @override
  Future<void> increaseQuantity(int productId) async {
    final items = loadItems();
    final idx = items.indexWhere((e) => e.product.id == productId);
    if (idx < 0) return;
    items[idx] = items[idx].copyWithQty(items[idx].quantity + 1);
    await _save(items);
  }

  @override
  Future<void> decreaseQuantity(int productId) async {
    final items = loadItems();
    final idx = items.indexWhere((e) => e.product.id == productId);
    if (idx < 0) return;

    final current = items[idx].quantity;
    if (current <= 1) {
      items.removeAt(idx);
    } else {
      items[idx] = items[idx].copyWithQty(current - 1);
    }
    await _save(items);
  }

  @override
  Future<void> removeItem(int productId) async {
    final items = loadItems();
    items.removeWhere((e) => e.product.id == productId);
    await _save(items);
  }

  @override
  Future<void> updateProduct(Product updated) async {
    final items = loadItems();
    final idx = items.indexWhere((e) => e.product.id == updated.id);
    if (idx < 0) return; // sản phẩm này không có trong giỏ, không cần làm gì

    items[idx] = CartItem(product: updated, quantity: items[idx].quantity);
    await _save(items);
  }

  @override
  Future<void> clearAll() async {
    await _dataSource.clear();
  }

  @override
  int get count => loadItems().length;

  Future<void> _save(List<CartItem> items) {
    return _dataSource.writeItems(items.map(CartItemMapper.toMap).toList());
  }
}
