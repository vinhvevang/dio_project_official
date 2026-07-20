import 'package:dio_complete/features/category/domain/entities/category.dart';


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
