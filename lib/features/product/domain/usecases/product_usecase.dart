import 'package:dio_complete/features/product/domain/entities/product.dart';
import 'package:dio_complete/features/product/domain/entities/product_payload.dart';
import 'package:dio_complete/features/product/domain/entities/product_result.dart';
import 'package:dio_complete/features/product/domain/repositories/product_repository.dart';

class ProductUseCase {
  final ProductRepository _repository;

  ProductUseCase(this._repository);

  Future<ProductResult> getProducts({required int page, int limit = 10}) {
    return _repository.getProducts(page: page, limit: limit);
  }

  Future<Product> getProductDetail(int id) => _repository.getProductDetail(id);

  Future<Product> createProduct(ProductPayload payload) =>
      _repository.createProduct(payload);

  Future<Product> updateProduct(int id, ProductPayload payload) =>
      _repository.updateProduct(id, payload);

  Future<void> deleteProduct(int id) => _repository.deleteProduct(id);

  Future<void> resetData() => _repository.resetData();
}
