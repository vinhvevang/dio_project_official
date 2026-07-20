import 'package:dio_complete/features/cart/domain/entities/cart_item.dart';
import 'package:dio_complete/features/product/data/models/product_model.dart';

class CartItemMapper {
  CartItemMapper._();

  static Map<String, dynamic> toMap(CartItem item) {
    final product = item.product;
    return {
      'product': {
        'id': product.id,
        'status': product.status,
        'created_at': product.createdAt,
        'updated_at': product.updatedAt,
        'name': product.name,
        'code': product.code,
        'price': product.price,
        'stock': product.stock,
        'description': product.description,
        'image': product.image,
        if (product.category != null)
          'category': {
            'id': product.category!.id,
            'status': product.category!.status,
            'created_at': product.category!.createdAt,
            'updated_at': product.category!.updatedAt,
            'name': product.category!.name,
          },
      },
      'quantity': item.quantity,
    };
  }


  static CartItem? fromMap(Map<String, dynamic> json) {
    final productJson = json['product'];
    if (productJson is! Map) return null;

    try {
      final product = ProductModel.fromJson(
        Map<String, dynamic>.from(productJson),
      ).toEntity();
      final quantity = json['quantity'];
      return CartItem(product: product, quantity: quantity is int ? quantity : 1);
    } catch (_) {
      return null;
    }
  }
}
