import 'package:dio_complete/features/product/domain/entities/product.dart';

/// Kết quả phân trang khi tải danh sách sản phẩm - chỉ phụ thuộc entity
/// domain [Product], KHÔNG phụ thuộc data/models (trước đây import nhầm
/// Product từ data/models/product_model.dart - vi phạm Clean Architecture:
/// domain không được phụ thuộc ngược lại data).
class ProductResult {
  final List<Product> products;
  final int page;
  final int limit;
  final int? count;

  ProductResult({
    required this.products,
    required this.page,
    required this.limit,
    required this.count,
  });
}
