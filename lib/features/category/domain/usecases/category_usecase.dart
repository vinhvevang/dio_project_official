import 'package:dio_complete/features/category/domain/entities/category.dart';
import 'package:dio_complete/features/category/domain/entities/category_payload.dart';
import 'package:dio_complete/features/category/domain/repositories/category_repository.dart';

class CategoryUseCase {
  final CategoryRepository _repository;

  CategoryUseCase(this._repository);

  Future<List<Category>> loadCategories() => _repository.getCategories();

  Future<int> createCategory(CategoryPayload payload) =>
      _repository.createCategory(payload);

  Future<void> updateCategory(int id, CategoryPayload payload) =>
      _repository.updateCategory(id, payload);

  Future<void> deleteCategory(int id) => _repository.deleteCategory(id);
}
