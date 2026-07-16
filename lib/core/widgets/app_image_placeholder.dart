import 'package:flutter/material.dart';


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
