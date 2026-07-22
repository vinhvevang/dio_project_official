import 'package:dio_complete/core/network/base_dio_datasource.dart';

/// Tầng datasource - chỉ biết GỌI API và trả nguyên `response.data`. Xem
/// product_remote_datasource.dart để biết đầy đủ lý do tách lớp này.
abstract class CategoryRemoteDataSource {
  Future<dynamic> getCategories();

  Future<dynamic> createCategory(Map<String, dynamic> payloadJson);

  Future<void> updateCategory(int id, Map<String, dynamic> payloadJson);

  Future<void> deleteCategory(int id);
}

class CategoryRemoteDataSourceImpl extends BaseDioDataSource
    implements CategoryRemoteDataSource {
  @override
  Future<dynamic> getCategories() {
    return run(() async {
      final response = await dio.get('/categories');
      return response.data;
    }, fallbackMessage: 'Tải danh mục thất bại');
  }

  @override
  Future<dynamic> createCategory(Map<String, dynamic> payloadJson) {
    return run(() async {
      final response = await dio.post('/categories', data: payloadJson);
      return response.data;
    }, fallbackMessage: 'Tạo danh mục thất bại');
  }

  @override
  Future<void> updateCategory(int id, Map<String, dynamic> payloadJson) {
    return run<void>(() async {
      await dio.put('/categories/$id', data: payloadJson);
    }, fallbackMessage: 'Cập nhật danh mục thất bại');
  }

  @override
  Future<void> deleteCategory(int id) {
    return run<void>(() async {
      await dio.delete('/categories/$id');
    }, fallbackMessage: 'Xóa danh mục thất bại');
  }
}
