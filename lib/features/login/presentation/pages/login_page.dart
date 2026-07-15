import 'package:dio_complete/core/widgets/app_colors.dart';
import 'package:dio_complete/core/widgets/app_images.dart';
import 'package:dio_complete/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:dio_complete/features/login/presentation/controllers/login_controller.dart';
import 'package:dio_complete/features/login/presentation/validators/auth_validators.dart';
import 'package:svg_image/svg_image.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: const _LoginFormBody(),
        ),
      ),
    );
  }
}

/// Obx CHỈ bọc đúng [Form] (cần đọc hasSubmittedOnce để quyết định
/// autovalidateMode) - các field bên trong (tách ở [_LoginFormFields], 1
/// widget const riêng) không tự set autovalidateMode nữa mà THỪA HƯỞNG từ
/// Form cha (TextFormField khi không set riêng sẽ tự lấy autovalidateMode từ
/// Form bao ngoài) - giống hệt cách product_form_page.dart đã làm. Vừa hết
/// lặp lại cùng 1 biểu thức 3 chỗ (Form + từng field tự tính riêng như
/// trước), vừa tránh phải dựng lại toàn bộ field mỗi khi hasSubmittedOnce đổi
/// giá trị.
class _LoginFormBody extends GetView<LoginController> {
  const _LoginFormBody();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Form(
        key: controller.formKey,
        autovalidateMode: controller.hasSubmittedOnce.value
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        child: const _LoginFormFields(),
      ),
    );
  }
}

class _LoginFormFields extends GetView<LoginController> {
  const _LoginFormFields();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 100,
          width: 200,
          child: SvgPicture.asset(AppImages.biglogo, fit: BoxFit.contain),
        ),
        AppTextFormField(
          controller: controller.usernameController,
          focusNode: controller.usernameFocusNode,
          nextFocus: controller.passwordFocusNode,
          label: 'Tên đăng nhập',
          required: true,
          prefixIcon: const Icon(Icons.person_outline),
          validator: AuthValidators.username,
          onChanged: (_) => controller.clearAuthError(),
        ),
        const SizedBox(height: 16),
        const _PasswordField(),
        const SizedBox(height: 16),
        const _AuthErrorText(),
        const SizedBox(height: 16),
        const _LoginButton(),
      ],
    );
  }
}

class _PasswordField extends GetView<LoginController> {
  const _PasswordField();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppTextFormField(
        controller: controller.passwordController,
        focusNode: controller.passwordFocusNode,
        label: 'Mật khẩu',
        required: true,
        prefixIcon: const Icon(Icons.lock_outline),
        obscureText: controller.obscurePassword.value,
        textInputAction: TextInputAction.done,
        validator: AuthValidators.password,
        // Field này tự truyền suffixIcon (icon con mắt) nên AppTextFormField
        // sẽ KHÔNG tự hiện nút "x" mặc định của nó nữa (widget chỉ hiện 1
        // trong 2). Ghép chung nút "x" (chỉ hiện khi có chữ, y hệt cách
        // username đang có) vào đây, đặt bên trái icon con mắt.
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller.passwordController,
              builder: (context, value, _) {
                if (value.text.isEmpty) return const SizedBox.shrink();
                return IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  onPressed: () {
                    controller.passwordController.clear();
                    controller.clearAuthError();
                  },
                );
              },
            ),
            IconButton(
              icon: Icon(
                controller.obscurePassword.value
                    ? Icons.visibility_off
                    : Icons.visibility,
              ),
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              onPressed: controller.togglePasswordVisibility,
            ),
          ],
        ),
        onChanged: (_) => controller.clearAuthError(),
        onSubmit: controller.login,
      ),
    );
  }
}

class _AuthErrorText extends GetView<LoginController> {
  const _AuthErrorText();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.authError.value.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          controller.authError.value,
          style: TextStyle(color: Colors.red.shade700),
        ),
      );
    });
  }
}

class _LoginButton extends GetView<LoginController> {
  const _LoginButton();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: controller.isLoading.value ? null : controller.login,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: controller.isLoading.value
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text(
                  'Đăng nhập',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }
}
