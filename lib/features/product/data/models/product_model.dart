import 'package:dio_complete/features/category/data/models/category_model.dart';
import 'package:dio_complete/features/product/domain/entities/product.dart';

class ProductModel {
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
  final CategoryModel? category;

  const ProductModel({
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

  Product toEntity() {
    return Product(
      id: id,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      name: name,
      code: code,
      price: price,
      stock: stock,
      description: description,
      image: image,
      category: category?.toEntity(),
    );
  }


  static const _placeholderImageUrl = '';

  static String _normalizeImage(dynamic value) {
    final raw = value is String ? value.trim() : '';
    return raw == _placeholderImageUrl ? '' : raw;
  }


  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
