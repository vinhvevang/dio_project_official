import 'package:dio/dio.dart';
import 'package:dio_complete/core/network/base_dio_repository.dart';
import 'package:dio_complete/core/network/dio_error_mapper.dart';
import 'package:dio_complete/features/product/data/mappers/product_payload_mapper.dart';
import 'package:dio_complete/features/product/data/models/product_model.dart';
import 'package:dio_complete/features/product/domain/entities/product.dart';
import 'package:dio_complete/features/product/domain/entities/product_payload.dart';
import 'package:dio_complete/features/product/domain/entities/product_result.dart';
import 'package:dio_complete/features/product/domain/repositories/product_repository.dart';

class ProductRepositoryImpl extends BaseDioRepository
    implements ProductRepository {
  List<Product> _extractProducts(dynamic raw) => asMapList(unwrapData(raw))
      .map(ProductModel.fromJson)
      .map((model) => model.toEntity())
      .toList();

  Map<String, dynamic> _extractSingleProductMap(dynamic raw) {
    final node = unwrapData(raw);
    if (node is List) {
      if (node.isEmpty) {
        throw Exception('Server không trả về dữ liệu sản phẩm');
      }
      return asStringKeyedMap(node.first);
    }
    return asStringKeyedMap(node);
  }

  Future<Product> _findProductById(int id) async {
    final result = await getProducts(page: 1, limit: 1000);
    for (final product in result.products) {
      if (product.id == id) return product;
    }
    throw Exception('Không tìm thấy sản phẩm');
  }

  @override
  Future<ProductResult> getProducts({required int page, int limit = 10}) {
    return run(() async {
      final response = await dio.get(
        '/products',
        queryParameters: {'page': page, 'limit': limit},
      );
      final products = _extractProducts(response.data);
      final rawPaging = response.data is Map ? response.data['paging'] : null;
      final pagingMap = rawPaging is Map ? asStringKeyedMap(rawPaging) : const <String, dynamic>{};

      final rawCount = pagingMap['count'];
      final rawPage = pagingMap['page'];
      final rawLimit = pagingMap['limit'];

      return ProductResult(
        products: products,
        page: rawPage is int ? rawPage : page,
        limit: rawLimit is int ? rawLimit : limit,
        count: rawCount is num && rawCount > 0 ? rawCount.toInt() : null,
      );
    }, fallbackMessage: 'Tải danh sách sản phẩm thất bại');
  }

  @override
  Future<Product> getProductDetail(int id) async {
    try {
      final response = await dio.get('/products/$id');
      return ProductModel.fromJson(_extractSingleProductMap(response.data)).toEntity();
    } on DioException catch (e) {
      
      if (e.response?.statusCode == 404) return _findProductById(id);
      throw Exception(dioErrorMessage(e, 'Tải chi tiết sản phẩm thất bại'));
    } catch (e) {
      return _findProductById(id);
    }
  }

  @override
  Future<Product> createProduct(ProductPayload payload) {
    return run(() async {
      final response = await dio.post('/products', data: payload.toJson());
      final node = unwrapData(response.data);

      // Trường hợp thường gặp: backend trả về nguyên object sản phẩm vừa tạo.
      if (node is Map || node is List) {
        return ProductModel.fromJson(_extractSingleProductMap(node))
            .toEntity()

            .copyWith(category: payload.category);
      }

      
      if (node is num) {
        return getProductDetail(node.toInt());
      }

      throw Exception('Không lấy được dữ liệu sản phẩm vừa tạo');
    }, fallbackMessage: 'Tạo sản phẩm thất bại');
  }

  @override
  Future<Product> updateProduct(int id, ProductPayload payload) {
    return run(() async {
      final response = await dio.put('/products/$id', data: payload.toJson());
      final node = unwrapData(response.data);

      if (node is Map || node is List) {
        return ProductModel.fromJson(_extractSingleProductMap(node))
            .toEntity()
            .copyWith(category: payload.category);
      }

      return getProductDetail(id);
    }, fallbackMessage: 'Cập nhật sản phẩm thất bại');
  }

  @override
  Future<void> deleteProduct(int id) {
    return run<void>(() async {
      await dio.delete('/products/$id');
    }, fallbackMessage: 'Xóa sản phẩm thất bại');
  }

  @override
  Future<void> resetData() {
    return run<void>(() async {
      await dio.get('/reset');
    }, fallbackMessage: 'Reset dữ liệu thất bại');
  }
}
