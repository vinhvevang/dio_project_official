import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio_complete/core/widgets/app_colors.dart';
import 'package:dio_complete/features/category/domain/entities/category.dart';
import 'package:dio_complete/features/category/presentation/controllers/category_controller.dart';
import 'package:dio_complete/features/product/presentation/controllers/home_controller.dart';

/// Mở bottom sheet bộ lọc (danh mục + giá mục tiêu).
///
/// [draftCategory] được tạo Ở ĐÂY - đúng 1 lần cho mỗi lần mở sheet - rồi
/// truyền xuống [ProductFilterSheet] qua constructor thay vì để widget tự
/// tạo bên trong build(). Nếu tạo trong build(), lựa chọn nháp sẽ bị mất mỗi
/// khi sheet rebuild vì lý do không liên quan (bàn phím ẩn/hiện, xoay màn
/// hình...) - build() của 1 StatelessWidget có thể được gọi lại nhiều lần dù
/// không có setState nào cả.
Future<void> showProductFilterSheet(BuildContext context) {
  final categoryController = Get.find<CategoryController>();
  final draftCategory = Rx<Category?>(categoryController.selectedCategory.value);

  return Get.bottomSheet(
    ProductFilterSheet(draftCategory: draftCategory),
    isScrollControlled: true,
  );
}

class ProductFilterSheet extends GetView<HomeController> {
  final Rx<Category?> draftCategory;

  const ProductFilterSheet({super.key, required this.draftCategory});

  @override
  Widget build(BuildContext context) {
    final categoryController = Get.find<CategoryController>();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Bộ lọc',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  controller.clearPriceFilter();
                  categoryController.selectedCategory.value = null;
                  Get.back();
                },
                child: const Text('Xóa lọc', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          const Text(
            'Danh mục',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _CategoryChips(
            categoryController: categoryController,
            draftCategory: draftCategory,
          ),

          const SizedBox(height: 16),
          const Text(
            'Giá mục tiêu',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text(
            'Nhập giá mục tiêu. Danh sách sẽ sắp xếp sản phẩm có giá gần nhất lên đầu.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller.priceFilterController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Giá mục tiêu (đ)',
              hintText: 'VD: 500000',
              prefixIcon: const Icon(Icons.attach_money),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () {
                // Chỉ tới đây (bấm Áp dụng) danh mục nháp mới được ghi vào
                // state thật -> HomeController mới lọc lại danh sách.
                categoryController.selectedCategory.value = draftCategory.value;
                controller.applyPriceFilter(); // hàm này đã tự Get.back()
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Áp dụng'),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final CategoryController categoryController;
  final Rx<Category?> draftCategory;

  const _CategoryChips({
    required this.categoryController,
    required this.draftCategory,
  });

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      selectedColor: AppColors.primary,
      backgroundColor: Colors.grey.shade100,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primary : Colors.grey.shade300,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final categories = categoryController.categories;
      final selected = draftCategory.value;

      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildChip(
            label: 'Tất cả',
            isSelected: selected == null,
            onTap: () => draftCategory.value = null,
          ),
          ...categories.map((c) => _buildChip(
                label: c.name,
                isSelected: selected?.id == c.id,
                onTap: () => draftCategory.value = c,
              )),
        ],
      );
    });
  }
}
