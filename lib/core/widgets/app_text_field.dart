import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio_complete/core/widgets/app_field_label.dart';

class AppTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool required;
  final String? hintText;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? prefixIcon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function(String)? onChanged;
  final VoidCallback? onEditingComplete;
  final AutovalidateMode? autovalidateMode;
  final Widget? suffixIcon;
  final bool autofocus;

  /// Nếu có: nhấn Enter/Next tự chuyển focus sang field này.
  final FocusNode? nextFocus;

  final VoidCallback? onSubmit;

  const AppTextFormField({
    super.key,
    required this.controller,
    required this.label,
    this.required = false,
    this.hintText,
    this.validator,
    this.obscureText = false,
    this.prefixIcon,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.focusNode,
    this.textInputAction,
    this.onChanged,
    this.onEditingComplete,
    this.nextFocus,
    this.onSubmit,
    this.autovalidateMode,
    this.suffixIcon,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTextInputAction =
        textInputAction ??
        (nextFocus != null
            ? TextInputAction.next
            : (onSubmit != null ? TextInputAction.done : null));

    void handleEditingComplete() {
      if (nextFocus != null) {
        FocusScope.of(context).requestFocus(nextFocus);
      } else if (onSubmit != null) {
        FocusScope.of(context).unfocus();
        onSubmit!();
      }
      onEditingComplete?.call();
    }

    Widget? buildSuffixIcon() {
      if (suffixIcon != null) return suffixIcon;
      return ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) {
          if (value.text.isEmpty) return const SizedBox.shrink();
          return IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () {
              controller.clear();
              onChanged?.call('');
            },
          );
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppFieldLabel(label: label, required: required),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          autofocus: autofocus,
          obscureText: obscureText,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: obscureText ? 1 : maxLines,
          textInputAction: effectiveTextInputAction,
          onChanged: onChanged,
          onEditingComplete:
              (nextFocus != null ||
                  onSubmit != null ||
                  onEditingComplete != null)
              ? handleEditingComplete
              : null,
          autovalidateMode: autovalidateMode,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon,
            suffixIcon: buildSuffixIcon(),
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
