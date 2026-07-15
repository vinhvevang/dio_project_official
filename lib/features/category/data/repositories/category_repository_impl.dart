import 'package:dio_complete/core/network/base_dio_repository.dart';
import 'package:dio_complete/features/category/data/models/category_model.dart';
import 'package:dio_complete/features/category/data/models/category_payload.dart';
import 'package:dio_complete/features/category/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl extends BaseDioRepository
    implements CategoryRepository {
  @override
  Future<List<Category>> getCategories() {
    return run(() async {
      final response = await dio.get('/categories');
      return asMapList(unwrapData(response.data)).map(Category.fromJson).toList();
    }, fallbackMessage: 'Tải danh mục thất bại');
  }

  /// Trả về id của danh mục vừa tạo - API chỉ trả { "data": <id> }, không trả
  /// nguyên object, nên phần gọi hàm này sẽ tự dựng Category cục bộ từ id này
  /// + name vừa nhập để cập nhật UI ngay, không cần gọi lại getCategories().
  @override
  Future<int> createCategory(CategoryPayload payload) {
    return run(() async {
      final response = await dio.post('/categories', data: payload.toJson());
      final node = unwrapData(response.data);

      if (node is num) return node.toInt();
      if (node is Map) {
        final id = node['id'];
        if (id is num) return id.toInt();
      }

      throw Exception('Không lấy được id danh mục vừa tạo');
    }, fallbackMessage: 'Tạo danh mục thất bại');
  }

  @override
  Future<void> updateCategory(int id, CategoryPayload payload) {
    return run<void>(() async {
      await dio.put('/categories/$id', data: payload.toJson());
    }, fallbackMessage: 'Cập nhật danh mục thất bại');
  }

  @override
  Future<void> deleteCategory(int id) {
    return run<void>(() async {
      await dio.delete('/categories/$id');
    }, fallbackMessage: 'Xóa danh mục thất bại');
  }
}
