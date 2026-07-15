import 'package:dio_complete/features/category/domain/entities/category.dart';

/// Model ĐỌC dữ liệu danh mục - đại diện ĐÚNG shape JSON mà backend GET trả
/// về.
///
/// KHÔNG kế thừa (`extends`) entity domain [Category] - kế thừa khiến Model
/// "giả làm" Entity bằng quan hệ is-a của Dart, không hề có bước CHUYỂN ĐỔI
/// tường minh nào cả (chỉ đơn thuần dùng được ở chỗ cần Category vì đúng kiểu
/// con). Ở đây Model và Entity là 2 class HOÀN TOÀN TÁCH BIỆT; [toEntity]
/// mới là logic chuyển đổi thật sự, và đây cũng là RANH GIỚI DUY NHẤT mà
/// data layer "chạm" vào domain layer (data biết domain để convert sang,
/// domain không hề biết gì về data).
class CategoryModel {
  final int id;
  final int status;
  final String createdAt;
  final String updatedAt;
  final String name;

  const CategoryModel({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
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

  /// Chuyển Model (data, đúng shape JSON) sang Entity (domain, thuần nghiệp
  /// vụ, không biết gì về JSON) - luôn gọi hàm này ở repository trước khi
  /// trả dữ liệu ra khỏi data layer, để usecase/controller/UI không bao giờ
  /// thấy kiểu CategoryModel, chỉ thấy đúng Category.
  Category toEntity() {
    return Category(
      id: id,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      name: name,
    );
  }
}
