import 'package:dio_complete/features/category/data/models/category_model.dart';

/// Model ĐỌC dữ liệu sản phẩm - đại diện ĐÚNG shape JSON mà backend GET trả
/// về. Chỉ còn field + constructor thuần túy - toàn bộ logic chuyển đổi
/// (fromJson/toEntity/toJson) đã chuyển sang ProductMapper
/// (data/mappers/product_mapper.dart) để 1 nơi duy nhất chứa hết logic
/// "dịch" dữ liệu, Model chỉ còn là khuôn dữ liệu.
///
/// KHÔNG kế thừa (`extends`) entity domain Product - xem category_model.dart
/// để biết đầy đủ lý do. [category] ở đây là CategoryModel (data), không
/// phải Category (domain) - convert cả 2 cùng lúc trong ProductMapper.toEntity.
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
}
