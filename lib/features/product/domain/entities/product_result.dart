import 'package:dio_complete/features/product/domain/entities/product.dart';

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
