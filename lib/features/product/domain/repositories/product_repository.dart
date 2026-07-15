import 'package:dio_complete/features/product/domain/entities/product.dart';
import 'package:dio_complete/features/product/domain/entities/product_payload.dart';
import 'package:dio_complete/features/product/domain/entities/product_result.dart';

abstract class ProductRepository {
  Future<ProductResult> getProducts({required int page, int limit = 10});
  Future<Product> getProductDetail(int id);
  Future<Product> createProduct(ProductPayload payload);
  Future<Product> updateProduct(int id, ProductPayload payload);
  Future<void> deleteProduct(int id);
  Future<void> resetData();
}
