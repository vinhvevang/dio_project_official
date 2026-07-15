import 'package:dio_complete/features/category/data/models/category_model.dart';
import 'package:dio_complete/features/product/domain/entities/product.dart';

/// Model ĐỌC dữ liệu sản phẩm - kế thừa entity domain [Product] và thêm đúng
/// 1 khả năng: parse từ JSON backend trả về (GET). Chiều GHI (tạo/sửa) dùng
/// [ProductPayload] (product_payload.dart) - vẫn tách riêng theo lý do cũ:
/// 2 chiều đọc/ghi khác shape JSON (đọc trả "category" object lồng, ghi nhận
/// "category_id" dạng số).
class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    required super.name,
    required super.code,
    required super.price,
    required super.stock,
    required super.description,
    required super.image,
    super.category,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      status: json['status'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      price: _parseDouble(json['price']),
      stock: json['stock'] ?? 0,
      description: json['description'] ?? '',
      image: _normalizeImage(json['image']),
      category: json['category'] is Map
          ? CategoryModel.fromJson(Map<String, dynamic>.from(json['category']))
          : null,
    );
  }

  /// Backend có 1 URL ảnh MẶC ĐỊNH/PLACEHOLDER còn sót lại từ lúc phát triển
  /// ("example.com" là domain IANA dành riêng cho tài liệu/ví dụ, không phải
  /// ảnh thật) - tự gán cho sản phẩm không có ảnh, KỂ CẢ khi client đã gửi
  /// lên null cho field ảnh lúc tạo/sửa. Coi giá trị này như "không có ảnh"
  /// (chuỗi rỗng) ngay tại đây - điểm phân tích JSON DUY NHẤT - để mọi nơi
  /// hiển thị/dùng tới ảnh sản phẩm (form sửa, lưới sản phẩm, trang chi
  /// tiết, giỏ hàng) đều tự động không hiện/không cố tải URL giả này, không
  /// cần sửa riêng từng nơi.
  static const _placeholderImageUrl = 'https://example.com/image.png';

  static String _normalizeImage(dynamic value) {
    final raw = value is String ? value.trim() : '';
    return raw == _placeholderImageUrl ? '' : raw;
  }

  /// Ép "price" về double an toàn: backend luôn trả số, nhưng phòng trường
  /// hợp trả về dạng chuỗi ("120000") thì vẫn parse được thay vì crash bằng
  /// 1 phép `as num` cứng.
  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
