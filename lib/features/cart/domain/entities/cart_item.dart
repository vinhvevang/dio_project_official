import 'package:dio_complete/features/product/domain/entities/product.dart';

class CartItem {
  final Product product;
  final int quantity;

  CartItem({required this.product, required this.quantity});

  CartItem copyWithQty(int qty) => CartItem(product: product, quantity: qty);
}