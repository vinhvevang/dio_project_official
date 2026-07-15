import 'package:dio_complete/features/category/domain/entities/category.dart';

/// Entity DOMAIN của sản phẩm - object nghiệp vụ thuần, KHÔNG biết gì về
/// JSON/HTTP (không có fromJson/toJson). Domain layer chỉ nên phụ thuộc vào
/// entity, không được phụ thuộc ngược lại data layer.
///
/// [ProductModel] (data/models/product_model.dart) kế thừa class này và
/// thêm `fromJson` - vì ProductModel LÀ MỘT Product (is-a, qua `extends`),
/// mọi nơi cần kiểu `Product` (usecase, controller, UI) đều nhận trực tiếp
/// instance ProductModel repository trả về mà không cần bước "map" riêng,
/// trong khi domain/entities vẫn không hề import ngược về data/models.
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

  /// Backend trả danh mục dưới dạng OBJECT LỒNG (không phải category_id
  /// phẳng) khi đọc. Nullable vì sản phẩm có thể chưa được gán danh mục.
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
