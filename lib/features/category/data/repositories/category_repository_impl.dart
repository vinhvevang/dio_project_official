import 'package:dio_complete/core/network/json_shape_helper.dart';
import 'package:dio_complete/features/category/data/datasources/category_remote_datasource.dart';
import 'package:dio_complete/features/category/data/mappers/category_mapper.dart';
import 'package:dio_complete/features/category/domain/entities/category.dart';
import 'package:dio_complete/features/category/domain/entities/category_payload.dart';
import 'package:dio_complete/features/category/domain/repositories/category_repository.dart';

/// Repository giờ KHÔNG tự gọi dio nữa - mọi lời gọi mạng đi qua
/// [CategoryRemoteDataSource]. Xem product_repository_impl.dart để biết đầy
/// đủ lý do tách lớp này.
class CategoryRepositoryImpl with JsonShapeHelper implements CategoryRepository {
  final CategoryRemoteDataSource _dataSource;

  CategoryRepositoryImpl(this._dataSource);

  @override
  Future<List<Category>> getCategories() async {
    final raw = await _dataSource.getCategories();
    return asMapList(unwrapData(raw))
        .map(CategoryMapper.fromJson)
        .map(CategoryMapper.toEntity)
        .toList();
  }

  @override
  Future<int> createCategory(CategoryPayload payload) async {
    final raw = await _dataSource.createCategory(CategoryMapper.toJson(payload));
    final node = unwrapData(raw);

    if (node is num) return node.toInt();
    if (node is Map) {
      final id = node['id'];
      if (id is num) return id.toInt();
    }

    throw Exception('Không lấy được id danh mục vừa tạo');
  }

  @override
  Future<void> updateCategory(int id, CategoryPayload payload) {
    return _dataSource.updateCategory(id, CategoryMapper.toJson(payload));
  }

  @override
  Future<void> deleteCategory(int id) => _dataSource.deleteCategory(id);
}
