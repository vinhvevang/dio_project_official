import 'package:dio_complete/data/models/category_model.dart';
import 'package:dio_complete/data/models/product_model.dart';
import 'package:dio_complete/data/services/product_service.dart';
import 'package:dio_complete/domain/entities/product_result.dart';
import 'package:dio_complete/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductService _service = ProductService();

  @override
  Future<ProductResult> getProducts({required int page, int limit = 10}) {
    return _service.getProducts(page: page, limit: limit);
  }

  @override
  Future<Product> getProductDetail(int id) => _service.getProductDetail(id);

  @override
  Future<Product> createProduct({
    required String name,
    required String code,
    required double price,
    required int stock,
    required String description,
    required String image,
    required Category category,
  }) {
    return _service.createProduct(
      name: name,
      code: code,
      price: price,
      stock: stock,
      description: description,
      image: image,
      category: category,
    );
  }

  @override
  Future<Product> updateProduct({
    required int id,
    required String name,
    required String code,
    required double price,
    required int stock,
    required String description,
    required String image,
    required Category category,
  }) {
    return _service.updateProduct(
      id: id,
      name: name,
      code: code,
      price: price,
      stock: stock,
      description: description,
      image: image,
      category: category,
    );
  }

  @override
  Future<void> deleteProduct(int id) => _service.deleteProduct(id);

  @override
  Future<void> resetData() => _service.resetData();
}