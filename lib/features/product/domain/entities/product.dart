import 'package:dio_complete/features/category/domain/entities/category.dart';

/// Entity DOMAIN của sản phẩm - object nghiệp vụ thuần, KHÔNG biết gì về
/// JSON/HTTP (không có fromJson/toJson). Domain layer chỉ nên phụ thuộc vào
/// entity, không được phụ thuộc ngược lại data layer.
///
/// [ProductModel] (data/models/product_model.dart) là 1 class HOÀN TOÀN
/// TÁCH BIỆT (không kế thừa class này) đại diện đúng shape JSON backend trả
/// về; nó có `fromJson` để parse và `toEntity()` để CHUYỂN ĐỔI tường minh
/// sang [Product] này. Repository luôn gọi `toEntity()` trước khi trả dữ
/// liệu ra khỏi data layer, nên usecase/controller/UI chỉ bao giờ thấy đúng
/// [Product], không bao giờ thấy `ProductModel`.
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
