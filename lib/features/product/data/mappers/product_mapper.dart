import 'package:dio_complete/features/category/data/mappers/category_mapper.dart';
import 'package:dio_complete/features/category/data/models/category_model.dart';
import 'package:dio_complete/features/product/data/models/product_model.dart';
import 'package:dio_complete/features/product/domain/entities/product.dart';
import 'package:dio_complete/features/product/domain/entities/product_payload.dart';

/// Gộp cả 3 chiều chuyển đổi dữ liệu của Product vào 1 chỗ:
/// - fromJson: JSON (backend GET trả về) -> ProductModel
/// - toEntity: ProductModel -> Product (domain, dùng ở usecase/UI)
/// - toJson: ProductPayload (domain, ghi) -> JSON (gửi lên backend)
///
/// Trước đây fromJson/toEntity là method viết thẳng trên ProductModel, còn
/// toJson nằm ở 1 file extension riêng (product_payload_mapper.dart) - gộp
/// về đây cho cả đọc lẫn ghi đều có 1 nơi duy nhất để tìm/sửa. Xem thêm
/// category_mapper.dart (áp dụng cùng nguyên tắc).
class ProductMapper {
  ProductMapper._();

  static ProductModel fromJson(Map<String, dynamic> json) {
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
          ? CategoryMapper.fromJson(Map<String, dynamic>.from(json['category']))
          : null,
    );
  }

  /// Đây là ranh giới duy nhất mà data layer "chạm" vào domain layer. Convert
  /// luôn category lồng bên trong (nếu có) sang Category domain tương ứng
  /// qua chính CategoryMapper.toEntity - không lặp lại logic map field.
  static Product toEntity(ProductModel model) {
    final CategoryModel? categoryModel = model.category;
    return Product(
      id: model.id,
      status: model.status,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      name: model.name,
      code: model.code,
      price: model.price,
      stock: model.stock,
      description: model.description,
      image: model.image,
      category: categoryModel != null ? CategoryMapper.toEntity(categoryModel) : null,
    );
  }

  static Map<String, dynamic> toJson(ProductPayload payload) {
    return {
      'name': payload.name,
      'code': payload.code,
      'price': payload.price,
      'stock': payload.stock,
      'description': payload.description,
      'image': payload.image.isEmpty ? null : payload.image,
      'category_id': payload.category.id,
    };
  }

  /// Backend có 1 URL ảnh MẶC ĐỊNH/PLACEHOLDER còn sót lại từ lúc phát triển
  /// - tự gán cho sản phẩm không có ảnh. Coi giá trị này như "không có ảnh"
  /// (chuỗi rỗng) ngay tại đây - điểm phân tích JSON DUY NHẤT.
  static const _placeholderImageUrl = '';

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
