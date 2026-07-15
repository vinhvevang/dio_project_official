import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio_complete/core/widgets/confirm_dialog.dart';
import 'package:dio_complete/core/widgets/app_message_dialog.dart';
import 'package:dio_complete/features/category/domain/entities/category.dart';
import 'package:dio_complete/features/category/domain/entities/category_payload.dart';
import 'package:dio_complete/features/category/domain/usecases/category_usecase.dart';
import 'package:dio_complete/features/category/presentation/controllers/category_form_controller.dart';
import 'package:dio_complete/features/category/presentation/widgets/category_form_dialog.dart';

class CategoryController extends GetxController {
  final _categoryUseCase = Get.find<CategoryUseCase>();

  final categories = <Category>[].obs;

  /// null nghĩa là "Tất cả sản phẩm" (không lọc theo danh mục nào).
  final selectedCategory = Rx<Category?>(null);

  final isLoading = false.obs;
  final isSubmittingCategory = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  Future<void> loadCategories() async {
    isLoading.value = true;
    try {
      categories.assignAll(await _categoryUseCase.loadCategories());
    } catch (e) {
      await showAppMessageDialog(
        title: 'Lỗi',
        message: e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Chọn danh mục để lọc sản phẩm ở Home, rồi đóng Drawer lại.
  void selectCategory(Category? category) {
    selectedCategory.value = category;
    Get.back();
  }

  Future<void> openAddDialog() async {
    final formController = CategoryFormController();

    final name = await Get.dialog<String>(
      CategoryFormDialog(controller: formController),
    );

    if (name == null) return;

    isSubmittingCategory.value = true;
    try {
      final id = await _categoryUseCase.createCategory(
        CategoryPayload(name: name),
      );
      // API tạo danh mục chỉ trả về id (data: 5), không trả nguyên object,
      // nên tự dựng Category cục bộ để cập nhật danh sách ngay, không cần
      // gọi lại loadCategories().
      final now = DateTime.now().toIso8601String();
      categories.add(
        Category(id: id, status: 1, createdAt: now, updatedAt: now, name: name),
      );
      Get.snackbar(
        'Thành công',
        'Đã thêm danh mục "$name"',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
      );
    } catch (e) {
      await showAppMessageDialog(
        title: 'Lỗi',
        message: e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      isSubmittingCategory.value = false;
    }
  }

  Future<void> openEditDialog(Category category) async {
    final formController = CategoryFormController(initial: category);

    final name = await Get.dialog<String>(
      CategoryFormDialog(controller: formController),
    );

    if (name == null) return;

    try {
      await _categoryUseCase.updateCategory(
        category.id,
        CategoryPayload(name: name),
      );

      final updated = category.copyWith(
        name: name,
        updatedAt: DateTime.now().toIso8601String(),
      );
      final index = categories.indexWhere((c) => c.id == category.id);
      if (index >= 0) categories[index] = updated;

      // Nếu đang lọc theo đúng danh mục vừa sửa, cập nhật luôn tên hiển thị.
      if (selectedCategory.value?.id == category.id) {
        selectedCategory.value = updated;
      }

      await showAppMessageDialog(
        title: 'Thành công',
        message: 'Đã cập nhật danh mục',
        isSuccess: true,
      );
    } catch (e) {
      await showAppMessageDialog(
        title: 'Lỗi',
        message: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> confirmAndDelete(Category category) async {
    final confirmed = await showConfirmDialog(
      title: 'Xóa danh mục',
      message: 'Xóa danh mục "${category.name}"? Thao tác này không thể hoàn tác.',
      confirmLabel: 'Xóa',
    );

    if (!confirmed) return;

    try {
      await _categoryUseCase.deleteCategory(category.id);
      categories.removeWhere((c) => c.id == category.id);

      // Đang lọc theo đúng danh mục vừa xóa -> quay về "Tất cả".
      if (selectedCategory.value?.id == category.id) {
        selectedCategory.value = null;
      }

      await showAppMessageDialog(
        title: 'Thành công',
        message: 'Đã xóa danh mục',
        isSuccess: true,
      );
    } catch (e) {
      await showAppMessageDialog(
        title: 'Lỗi',
        message: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }
}
