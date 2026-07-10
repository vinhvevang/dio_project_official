import 'package:dio_complete/data/models/category_model.dart';
import 'package:dio_complete/data/services/category_service.dart';
import 'package:dio_complete/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryService _service = CategoryService();

  @override
  Future<List<Category>> getCategories() => _service.getCategories();

  @override
  Future<int> createCategory({required String name}) =>
      _service.createCategory(name: name);

  @override
  Future<void> updateCategory({required int id, required String name}) =>
      _service.updateCategory(id: id, name: name);

  @override
  Future<void> deleteCategory(int id) => _service.deleteCategory(id);
}