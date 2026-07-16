import 'package:dio_complete/features/category/domain/entities/category.dart';


class ProductPayload {
  final String name;
  final String code;
  final double price;
  final int stock;
  final String description;
  final String image;
  final Category category;

  const ProductPayload({
    required this.name,
    required this.code,
    required this.price,
    required this.stock,
    required this.description,
    required this.image,
    required this.category,
  });
}
