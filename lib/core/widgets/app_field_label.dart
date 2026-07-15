import 'package:flutter/material.dart';

/// Nhãn tên field hiển thị PHÍA TRÊN ô nhập, kèm dấu * đỏ khi field bắt buộc.
///
/// Trước đây các form tự viết chữ "(bắt buộc)" lẫn vào ngay trong tên field
/// (VD: "Tên sản phẩm (bắt buộc)") và dùng labelText của TextFormField (nhãn
/// nổi BÊN TRONG viền input, dễ bị che/khó đọc khi ô đã có chữ). Widget này
/// tách nhãn ra thành 1 dòng Text riêng nằm trên ô nhập, và đánh dấu bắt buộc
/// bằng ký hiệu "*" màu đỏ chuẩn form thay vì viết chữ - dùng chung cho mọi
/// loại field (TextFormField, DropdownButtonFormField...), không riêng gì
/// [AppTextFormField].
class AppFieldLabel extends StatelessWidget {
  final String label;
  final bool required;

  const AppFieldLabel({super.key, required this.label, this.required = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          children: [
            TextSpan(text: label),
            if (required)
              const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
