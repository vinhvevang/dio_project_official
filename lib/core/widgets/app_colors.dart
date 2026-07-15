import 'package:flutter/material.dart';

/// Bảng màu dùng chung cho toàn app - tránh lặp lại các literal Color(...)
/// (đặc biệt là màu thương hiệu) ở hàng chục nơi khác nhau (AppBar, nút bấm,
/// icon...). Khi cần đổi màu thương hiệu, chỉ sửa đúng 1 chỗ ở đây.
class AppColors {
  AppColors._();

  static const primary = Color(0xFFF24E1E);
}
