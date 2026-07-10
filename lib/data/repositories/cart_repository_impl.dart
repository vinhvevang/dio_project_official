import 'package:dio_complete/data/models/product_model.dart';
import 'package:dio_complete/data/services/cart_service.dart';
import 'package:dio_complete/domain/entities/cart_item.dart';
import 'package:dio_complete/domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  final CartService _service = CartService();

  @override
  List<CartItem> loadItems() => _service.getItems();

  @override
  Future<void> addItem(Product product, {int quantity = 1}) =>
      _service.addItem(product, quantity: quantity);

  @override
  Future<void> increaseQuantity(int productId) =>
      _service.increaseQuantity(productId);

  @override
  Future<void> decreaseQuantity(int productId) =>
      _service.decreaseQuantity(productId);

  @override
  Future<void> removeItem(int productId) => _service.removeItem(productId);

  @override
  Future<void> clearAll() => _service.clearAll();

  @override
  int get count => _service.count;
}