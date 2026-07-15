import 'package:dio_complete/features/category/domain/entities/category.dart';
import 'package:dio_complete/features/category/domain/entities/category_payload.dart';

abstract class CategoryRepository {
  Future<List<Category>> getCategories();
  Future<int> createCategory(CategoryPayload payload);
  Future<void> updateCategory(int id, CategoryPayload payload);
  Future<void> deleteCategory(int id);
}
