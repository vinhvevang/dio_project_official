import 'package:dio_complete/features/category/domain/entities/category.dart';

class Product {
  final int id;
  final int status;
  final String createdAt;
  final String updatedAt;
  final String name;
  final String code;
  final double price;
  final int stock;
  final String description;
  final String image;

  final Category? category;

  /// Tiện dùng để so sánh/lọc mà không cần null-check category? mỗi lần.
  int? get categoryId => category?.id;

  const Product({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
    required this.code,
    required this.price,
    required this.stock,
    required this.description,
    required this.image,
    this.category,
  });

  Product copyWith({
    int? id,
    int? status,
    String? createdAt,
    String? updatedAt,
    String? name,
    String? code,
    double? price,
    int? stock,
    String? description,
    String? image,
    Category? category,
  }) {
    return Product(
      id: id ?? this.id,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      code: code ?? this.code,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      description: description ?? this.description,
      image: image ?? this.image,
      category: category ?? this.category,
    );
  }
}
