import 'package:dio_complete/features/category/data/models/category_model.dart';

/// Model ĐỌC dữ liệu sản phẩm (những gì backend trả về qua GET). Chiều GHI
/// (tạo/sửa sản phẩm) dùng 1 class khác - [ProductPayload] (product_payload
/// .dart) - vì 2 chiều có SHAPE JSON khác nhau (đọc trả "category" là object
/// lồng đầy đủ, ghi chỉ nhận "category_id" dạng số) nên tách hẳn 2 class thay
/// vì nhồi chung 1 class rồi phải giữ 1 toJson() không ai dùng tới.
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

  /// Backend trả danh mục dưới dạng OBJECT LỒNG "category": {...} (không phải
  /// field phẳng "category_id") - xác nhận từ dữ liệu thật lấy về từ GET
  /// /products. Nullable vì sản phẩm có thể chưa được gán danh mục.
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

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      status: json['status'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      price: _parseDouble(json['price']),
      stock: json['stock'] ?? 0,
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      category: json['category'] is Map
          ? Category.fromJson(Map<String, dynamic>.from(json['category']))
          : null,
    );
  }

  /// Ép "price" về double an toàn: backend luôn trả số, nhưng phòng trường
  /// hợp trả về dạng chuỗi ("120000") thì vẫn parse được thay vì crash bằng
  /// 1 phép `as num` cứng.
  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

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
