import 'package:dio/dio.dart';
import 'package:dio_complete/core/network/base_dio_repository.dart';
import 'package:dio_complete/core/network/dio_error_mapper.dart';
import 'package:dio_complete/features/product/data/models/product_model.dart';
import 'package:dio_complete/features/product/data/models/product_payload.dart';
import 'package:dio_complete/features/product/domain/entities/product_result.dart';
import 'package:dio_complete/features/product/domain/repositories/product_repository.dart';

class ProductRepositoryImpl extends BaseDioRepository
    implements ProductRepository {
  List<Product> _extractProducts(dynamic raw) =>
      asMapList(unwrapData(raw)).map(Product.fromJson).toList();

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
      return Product.fromJson(_extractSingleProductMap(response.data));
    } on DioException catch (e) {
      // 404 hoặc lỗi khác: BE này đôi khi không cho GET chi tiết trực tiếp dù
      // sản phẩm có tồn tại - dự phòng bằng cách tìm trong danh sách đầy đủ
      // thay vì báo lỗi ngay.
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
        return Product.fromJson(
          _extractSingleProductMap(node),
        ).copyWith(category: payload.category);
      }

      // Backend chỉ trả về id (số) của sản phẩm vừa tạo, không echo lại
      // object đầy đủ -> GỌI LẠI backend để lấy đúng dữ liệu đã lưu, KHÔNG tự
      // dựng (fake) 1 Product cục bộ từ input người dùng như trước đây. Dữ
      // liệu hiển thị luôn phải là dữ liệu backend XÁC NHẬN đã lưu, không
      // phải suy đoán từ input client (client không biết backend có chỉnh
      // sửa/validate lại giá trị nào không).
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
        return Product.fromJson(
          _extractSingleProductMap(node),
        ).copyWith(category: payload.category);
      }

      // Backend không echo lại object sản phẩm sau khi sửa -> gọi lại chi
      // tiết để lấy đúng dữ liệu thật (kể cả created_at gốc) từ backend,
      // thay vì tự dựng (fake) Product từ input client như cách làm cũ - đó
      // chính là nguyên nhân bug "ngày tạo = ngày cập nhật" trước đây khi rơi
      // vào nhánh này.
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
