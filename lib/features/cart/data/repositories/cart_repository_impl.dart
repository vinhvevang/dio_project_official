import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:dio_complete/features/cart/data/mappers/cart_item_mapper.dart';
import 'package:dio_complete/features/cart/domain/entities/cart_item.dart';
import 'package:dio_complete/features/cart/domain/repositories/cart_repository.dart';
import 'package:dio_complete/features/product/domain/entities/product.dart';

class CartRepositoryImpl implements CartRepository {
  static const _boxName = 'cartBox';
  static const _key = 'items';

  Box get _box => Hive.box(_boxName);

  /// Parse danh sách item thô (List<dynamic> lấy từ Hive hoặc jsonDecode) -
  /// dùng CartItemMapper.fromMap cho từng phần tử và LỌC BỎ (không throw)
  /// những bản ghi hỏng/sai định dạng, thay vì để 1 bản ghi lỗi làm crash cả
  /// màn giỏ hàng.
  List<CartItem> _parseItems(List<dynamic> raw) {
    return raw
        .whereType<Map>()
        .map((e) => CartItemMapper.fromMap(Map<String, dynamic>.from(e)))
        .whereType<CartItem>()
        .toList();
  }

  @override
  List<CartItem> loadItems() {
    final raw = _box.get(_key);
    if (raw == null) return [];
    if (raw is List) return _parseItems(raw);

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
    await _box.delete(_key);
  }

  @override
  int get count => loadItems().length;

  Future<void> _save(List<CartItem> items) async {
    await _box.put(_key, items.map(CartItemMapper.toMap).toList());
  }
}
