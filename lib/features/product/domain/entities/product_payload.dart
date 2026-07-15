import 'package:dio_complete/features/category/domain/entities/category.dart';

/// Dữ liệu GHI khi tạo/sửa sản phẩm - đặt ở domain (không phải data/models)
/// vì đây là "yêu cầu nghiệp vụ" (business request) mà usecase/repository
/// interface làm việc cùng, bản thân nó không biết gì về JSON/HTTP. Việc
/// biến nó thành JSON (toJson) là chi tiết data-layer, đặt ở
/// data/mappers/product_payload_mapper.dart - domain tuyệt đối không import
/// ngược về data.
///
/// Tách khỏi [Product] (entity ĐỌC) vì 2 chiều đọc/ghi có shape khác nhau
/// (ghi chỉ cần 1 Category để lấy id, đọc trả nguyên object Category lồng).
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
