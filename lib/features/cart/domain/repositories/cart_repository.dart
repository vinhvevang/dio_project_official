import 'package:dio_complete/features/product/domain/entities/product.dart';
import 'package:dio_complete/features/cart/domain/entities/cart_item.dart';

abstract class CartRepository {
  List<CartItem> loadItems();
  Future<void> addItem(Product product, {int quantity = 1});
  Future<void> increaseQuantity(int productId);
  Future<void> decreaseQuantity(int productId);
  Future<void> removeItem(int productId);
  Future<void> clearAll();

 
  Future<void> updateProduct(Product updated);

  int get count;
}