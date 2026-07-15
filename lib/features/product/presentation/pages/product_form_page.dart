import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio_complete/core/widgets/app_colors.dart';
import 'package:dio_complete/core/widgets/app_field_label.dart';
import 'package:dio_complete/core/widgets/app_text_field.dart';
import 'package:dio_complete/features/category/data/models/category_model.dart';
import 'package:dio_complete/features/product/presentation/controllers/product_form_controller.dart';

class ProductFormPage extends GetView<ProductFormController> {
  const ProductFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.isEditMode ? 'Sửa sản phẩm' : 'Thêm sản phẩm'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: _ProductFormBody(),
      ),
    );
  }
}

/// Obx ở đây CHỈ bọc đúng [Form] (cần đọc hasSubmittedOnce để quyết định
/// autovalidateMode) - nội dung bên trong tách thành [_ProductFormFields],
/// 1 widget const RIÊNG, nên khi hasSubmittedOnce đổi giá trị thì Flutter chỉ
/// cần build lại đúng node Form (đổi 1 tham số của nó), còn cây field bên
/// dưới được TÁI SỬ DỤNG nguyên vẹn (const) thay vì dựng lại từ đầu.
/// Trước đây Obx bọc thẳng ra ngoài toàn bộ Column chứa hết mọi field, khiến
/// cả cây form to phải build lại chỉ vì 1 cờ bool đổi giá trị.
class _ProductFormBody extends GetView<ProductFormController> {
  const _ProductFormBody();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Form(
        key: controller.formKey,
        autovalidateMode: controller.hasSubmittedOnce.value
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        child: const _ProductFormFields(),
      ),
    );
  }
}

class _ProductFormFields extends GetView<ProductFormController> {
  const _ProductFormFields();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Preview ảnh (reactive theo imageUrl observable) ──
        const _ImagePreview(),

        // ── Tên sản phẩm ────────────────────────────────────
        AppTextFormField(
          controller: controller.nameController,
          focusNode: controller.nameFocusNode,
          nextFocus: controller.codeFocusNode,
          label: 'Tên sản phẩm',
          required: true,
          hintText: 'Nhập tên sản phẩm',
          onChanged: (_) => controller.clearFieldError(),
          validator: (v) => (v == null || v.trim().isEmpty)
              ? 'Tên không được để trống'
              : null,
        ),
        const SizedBox(height: 12),

        // ── Mã sản phẩm ─────────────────────────────────────
        AppTextFormField(
          controller: controller.codeController,
          focusNode: controller.codeFocusNode,
          nextFocus: controller.priceFocusNode,
          label: 'Mã sản phẩm',
          required: true,
          hintText: 'VD: DHN-001',
          onChanged: (_) => controller.clearFieldError(),
          validator: (v) => (v == null || v.trim().isEmpty)
              ? 'Mã không được để trống'
              : null,
        ),
        const SizedBox(height: 12),

        // ── Giá ─────────────────────────────────────────────
        AppTextFormField(
          controller: controller.priceController,
          focusNode: controller.priceFocusNode,
          nextFocus: controller.stockFocusNode,
          label: 'Giá (đ)',
          required: true,
          hintText: 'VD: 120000',
          keyboardType: TextInputType.number,
          onChanged: (_) => controller.clearFieldError(),
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return 'Giá không được để trống';
            }
            final val = int.tryParse(v.trim());
            if (val == null) return 'Giá phải là số nguyên';
            if (val < 0) return 'Giá không được âm';
            return null;
          },
        ),
        const SizedBox(height: 12),

        // ── Số lượng ─────────────────────────────────────────
        // Field cuối trước Danh mục (Dropdown không nằm trong chuỗi focus vì
        // nó không phải bàn phím) - nên Enter ở đây chuyển luôn tới URL ảnh
        // (field văn bản tiếp theo sau Dropdown).
        AppTextFormField(
          controller: controller.stockController,
          focusNode: controller.stockFocusNode,
          nextFocus: controller.imageFocusNode,
          label: 'Số lượng',
          required: true,
          hintText: 'VD: 10',
          keyboardType: TextInputType.number,
          onChanged: (_) => controller.clearFieldError(),
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return 'Số lượng không được để trống';
            }
            final val = int.tryParse(v.trim());
            if (val == null) return 'Số lượng phải là số nguyên';
            if (val < 0) return 'Số lượng không được âm';
            return null;
          },
        ),
        const SizedBox(height: 12),

        // ── Danh mục ─────────────────────────────────────────
        const _CategoryDropdown(),
        const SizedBox(height: 12),

        // ── URL ảnh ──────────────────────────────────────────
        AppTextFormField(
          controller: controller.imageController,
          focusNode: controller.imageFocusNode,
          nextFocus: controller.descriptionFocusNode,
          label: 'URL ảnh',
          hintText: 'https://... (có thể để trống)',
          prefixIcon: const Icon(Icons.image_outlined),
          onChanged: (_) => controller.clearFieldError(),
          validator: (v) {
            final trimmed = v?.trim() ?? '';
            if (trimmed.isEmpty) return null; // được phép để trống
            final uri = Uri.tryParse(trimmed);
            if (uri == null || !uri.hasScheme) return 'URL không hợp lệ';
            return null;
          },
        ),
        const SizedBox(height: 12),

        // ── Mô tả ────────────────────────────────────────────
        // Field cuối cùng: nhấn Enter/Done coi như bấm nút submit.
        AppTextFormField(
          controller: controller.descriptionController,
          focusNode: controller.descriptionFocusNode,
          onSubmit: controller.submit,
          maxLines: 4,
          label: 'Mô tả',
          hintText: 'Nhập mô tả sản phẩm...',
          onChanged: (_) => controller.clearFieldError(),
        ),
        const _FieldErrorText(),
        const SizedBox(height: 24),

        // ── Nút submit ───────────────────────────────────────
        const _SubmitButton(),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _ImagePreview extends GetView<ProductFormController> {
  const _ImagePreview();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final url = controller.imageUrl.value;
      if (url.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              url,
              height: 160,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 60,
                color: Colors.grey.shade200,
                child: const Center(
                  child: Text(
                    'URL ảnh không hợp lệ',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _CategoryDropdown extends GetView<ProductFormController> {
  const _CategoryDropdown();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final categories = controller.categoryController.categories;

      if (controller.categoryController.isLoading.value && categories.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (categories.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: Colors.orange.shade800),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Chưa có danh mục nào. Mở menu bên trái (kéo từ mép trái) để tạo danh mục trước.',
                  style: TextStyle(fontSize: 12, color: Colors.orange.shade800),
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppFieldLabel(label: 'Danh mục', required: true),
          DropdownButtonFormField<Category>(
            value: controller.selectedCategory.value,
            hint: const Text('Chọn danh mục'),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.category_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            items: categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                .toList(),
            onChanged: (value) {
              controller.selectCategory(value);
              controller.clearFieldError();
            },
            validator: controller.validateCategory,
          ),
        ],
      );
    });
  }
}

class _FieldErrorText extends GetView<ProductFormController> {
  const _FieldErrorText();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.fieldError.value.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          controller.fieldError.value,
          style: TextStyle(color: Colors.red.shade700),
        ),
      );
    });
  }
}

class _SubmitButton extends GetView<ProductFormController> {
  const _SubmitButton();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          onPressed: controller.isLoading.value ? null : controller.submit,
          icon: controller.isLoading.value
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(
                  controller.isEditMode ? Icons.save : Icons.add_circle_outline,
                ),
          label: Text(
            controller.isLoading.value
                ? 'Đang xử lý...'
                : (controller.isEditMode ? 'Lưu thay đổi' : 'Tạo sản phẩm'),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
    );
  }
}
