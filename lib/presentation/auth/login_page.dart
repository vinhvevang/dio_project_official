import 'package:dio_complete/core/widgets/app_images.dart';
import 'package:dio_complete/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:dio_complete/presentation/auth/login_controller.dart';
import 'package:svg_image/svg_image.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Obx(
            () => Form(
              key: controller.formKey,
              autovalidateMode:
                  controller.hasSubmittedOnce.value
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 100,
                    width: 200,
                    child: SvgPicture.asset(
                      AppImages.biglogo,
                      fit: BoxFit.contain,
                    ),
                  ),
                  AppTextFormField(
                    controller: controller.usernameController,
                    focusNode: controller.usernameFocusNode,
                    nextFocus: controller.passwordFocusNode,
                    label: 'Tên đăng nhập',
                    prefixIcon: const Icon(Icons.person_outline),
                    autovalidateMode:
                        controller.hasSubmittedOnce.value
                            ? AutovalidateMode.onUserInteraction
                            : AutovalidateMode.disabled,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập tên đăng nhập';
                      }
                      return null;
                    },
                    onChanged: (_) => controller.clearAuthError(),
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => AppTextFormField(
                      controller: controller.passwordController,
                      focusNode: controller.passwordFocusNode,
                      label: 'Mật khẩu',
                      prefixIcon: const Icon(Icons.lock_outline),
                      obscureText: controller.obscurePassword.value,
                      textInputAction: TextInputAction.done,
                      autovalidateMode:
                          controller.hasSubmittedOnce.value
                              ? AutovalidateMode.onUserInteraction
                              : AutovalidateMode.disabled,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập mật khẩu';
                        }
                        return null;
                      },
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.obscurePassword.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: controller.togglePasswordVisibility,
                      ),
                      onChanged: (_) => controller.clearAuthError(),
                      onSubmit: controller.login,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    if (controller.authError.value.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        controller.authError.value,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed:
                            controller.isLoading.value ? null : controller.login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF24E1E),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child:
                            controller.isLoading.value
                                ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : const Text(
                                  'Đăng nhập',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
