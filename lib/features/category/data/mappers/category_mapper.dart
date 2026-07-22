import 'package:dio_complete/features/category/data/models/category_model.dart';
import 'package:dio_complete/features/category/domain/entities/category.dart';
import 'package:dio_complete/features/category/domain/entities/category_payload.dart';

/// Gộp cả 3 chiều chuyển đổi dữ liệu của Category vào 1 chỗ:
/// - fromJson: JSON (backend GET trả về) -> CategoryModel
/// - toEntity: CategoryModel -> Category (domain, dùng ở usecase/UI)
/// - toJson: CategoryPayload (domain, ghi) -> JSON (gửi lên backend)
///
/// Trước đây fromJson/toEntity là method viết thẳng trên CategoryModel, còn
/// toJson nằm ở 1 file extension riêng (category_payload_mapper.dart) - gộp
/// về đây cho cả đọc lẫn ghi đều có 1 nơi duy nhất để tìm/sửa.
class CategoryMapper {
  CategoryMapper._();

  static CategoryModel fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      status: json['status'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      name: json['name'] ?? '',
    );
  }

  /// Đây là ranh giới duy nhất mà data layer "chạm" vào domain layer.
  static Category toEntity(CategoryModel model) {
    return Category(
      id: model.id,
      status: model.status,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      name: model.name,
    );
  }

  static Map<String, dynamic> toJson(CategoryPayload payload) {
    return {'name': payload.name};
  }
}
