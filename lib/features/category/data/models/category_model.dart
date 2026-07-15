import 'package:dio_complete/features/category/domain/entities/category.dart';

/// Model ĐỌC dữ liệu danh mục - kế thừa entity domain [Category] và thêm
/// đúng 1 khả năng: parse từ JSON backend trả về. Repository trả về
/// [CategoryModel] nhưng khai báo kiểu [Category] (interface domain) vẫn
/// đúng vì CategoryModel LÀ MỘT Category.
class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    required super.name,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      status: json['status'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      name: json['name'] ?? '',
    );
  }
}
