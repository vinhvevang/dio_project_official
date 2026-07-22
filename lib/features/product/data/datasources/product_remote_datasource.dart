import 'package:dio_complete/core/network/base_dio_datasource.dart';

/// Tầng datasource - chỉ biết GỌI API và trả nguyên `response.data` (không
/// bóc envelope "data", không đụng tới paging, không parse Model/Entity) -
/// Repository nhận dữ liệu thô này rồi tự diễn giải hình dạng (qua
/// JsonShapeHelper) và chuyển sang Model/Entity (qua ProductMapper).
abstract class ProductRemoteDataSource {
  Future<dynamic> getProducts({required int page, required int limit});

  /// KHÔNG tự bắt lỗi 404 ở đây - để nguyên DioException bay lên cho
  /// Repository tự quyết định phương án dự phòng (tìm trong danh sách đầy
  /// đủ) khi backend không cho GET chi tiết trực tiếp dù sản phẩm tồn tại.
  Future<dynamic> getProductDetail(int id);

  Future<dynamic> createProduct(Map<String, dynamic> payloadJson);

  Future<dynamic> updateProduct(int id, Map<String, dynamic> payloadJson);

  Future<void> deleteProduct(int id);

  Future<void> resetData();
}

class ProductRemoteDataSourceImpl extends BaseDioDataSource
    implements ProductRemoteDataSource {
  @override
  Future<dynamic> getProducts({required int page, required int limit}) {
    return run(() async {
      final response = await dio.get(
        '/products',
        queryParameters: {'page': page, 'limit': limit},
      );
      return response.data;
    }, fallbackMessage: 'Tải danh sách sản phẩm thất bại');
  }

  @override
  Future<dynamic> getProductDetail(int id) async {
    // Không dùng run() ở đây - run() sẽ chuyển DioException thành 1
    // Exception chung, làm mất statusCode mà Repository cần đọc để quyết
    // định fallback (xem ProductRepository.getProductDetail).
    final response = await dio.get('/products/$id');
    return response.data;
  }

  @override
  Future<dynamic> createProduct(Map<String, dynamic> payloadJson) {
    return run(() async {
      final response = await dio.post('/products', data: payloadJson);
      return response.data;
    }, fallbackMessage: 'Tạo sản phẩm thất bại');
  }

  @override
  Future<dynamic> updateProduct(int id, Map<String, dynamic> payloadJson) {
    return run(() async {
      final response = await dio.put('/products/$id', data: payloadJson);
      return response.data;
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
