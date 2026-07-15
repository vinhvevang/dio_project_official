import 'package:dio_complete/features/cart/domain/entities/cart_item.dart';
import 'package:dio_complete/features/product/data/models/product_model.dart';

/// Chuyển đổi CartItem <-> Map để lưu xuống Hive.
///
/// Tách thành 1 CLASS mapper riêng (trước đây là extension trộn thẳng vào
/// CartRepositoryImpl) để tách bạch rõ trách nhiệm "map dữ liệu" khỏi "thao
/// tác lưu trữ" - dễ đọc, dễ test độc lập với Hive.
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

  /// Parse 1 item giỏ hàng đã lưu. Trả về null nếu bản ghi hỏng/sai định
  /// dạng (thay vì ném lỗi ra ngoài, hoặc tự dựng 1 Product rỗng vô nghĩa để
  /// "cho có") - nơi gọi (CartRepositoryImpl.loadItems) lọc bỏ các giá trị
  /// null này.
  ///
  /// Trước đây dùng `Map<String, dynamic>.from(json['product'] as Map)` -
  /// nếu bản ghi cũ/hỏng có 'product' là null hoặc sai kiểu, TypeError không
  /// bắt sẽ ném ra ngay lúc CartController.onInit() → app crash mỗi lần mở
  /// Cart cho tới khi xóa dữ liệu app. Giờ luôn trả về null an toàn thay vì
  /// throw, và bọc thêm try/catch phòng lỗi parse khác (VD field bị thiếu
  /// theo cách ProductModel.fromJson không tự chịu được).
  static CartItem? fromMap(Map<String, dynamic> json) {
    final productJson = json['product'];
    if (productJson is! Map) return null;

    try {
      final product = ProductModel.fromJson(Map<String, dynamic>.from(productJson));
      final quantity = json['quantity'];
      return CartItem(product: product, quantity: quantity is int ? quantity : 1);
    } catch (_) {
      return null;
    }
  }
}
