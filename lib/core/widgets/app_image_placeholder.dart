import 'package:flutter/material.dart';

/// Ô placeholder vuông dùng khi sản phẩm không có ảnh (hoặc ảnh lỗi/không tải
/// được). Trước đây Home, Giỏ hàng và dialog thêm-vào-giỏ mỗi nơi tự viết lại
/// 1 hàm `_placeholder()` giống hệt nhau (chỉ khác mỗi kích thước) - gộp lại
/// đây dùng chung, đổi 1 chỗ là áp dụng cho mọi nơi.
class AppImagePlaceholder extends StatelessWidget {
  final double size;
  final BorderRadius? borderRadius;

  const AppImagePlaceholder({super.key, this.size = 64, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: borderRadius,
      ),
      child: Icon(Icons.image, color: Colors.grey, size: size * 0.4),
    );
  }
}
