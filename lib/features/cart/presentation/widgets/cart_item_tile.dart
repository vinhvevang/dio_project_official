import 'package:flutter/material.dart';
import 'package:dio_complete/core/widgets/app_formatter.dart';
import 'package:dio_complete/core/widgets/app_image_placeholder.dart';
import 'package:dio_complete/features/cart/domain/entities/cart_item.dart';

/// 1 dòng sản phẩm trong danh sách giỏ hàng - tách khỏi ListView.builder của
/// CartPage để hàm build() của trang không phải ôm cả cây widget to (ảnh,
/// tên, giá, nút +/-, nút xóa...) lồng bên trong 1 itemBuilder ẩn danh.
///
/// CartItem không có id ổn định xuyên suốt kiểu String/int cố định để làm
/// ValueKey ngoài product.id, nên nếu cần key ổn định cho danh sách này thì
/// dùng `ValueKey(item.product.id)` ngay tại nơi gọi (ListView.builder) - bản
/// thân widget này không tự đặt key vì key phải gắn ở ĐÚNG vị trí danh sách
/// cha, không phải ở widget con.
class CartItemTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onTap;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const CartItemTile({
    super.key,
    required this.item,
    required this.onTap,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final product = item.product;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: product.image.isNotEmpty
                  ? Image.network(
                      product.image,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const AppImagePlaceholder(size: 60),
                    )
                  : const AppImagePlaceholder(size: 60),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: InkWell(
                onTap: onTap,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppFormatter.currency(product.price),
                      style: const TextStyle(color: Colors.blue, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _QuantityButton(icon: Icons.remove, onTap: onDecrease),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            '${item.quantity}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        _QuantityButton(icon: Icons.add, onTap: onIncrease),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AppFormatter.currency(product.price * item.quantity),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.blue.shade50,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 16, color: Colors.blue),
        ),
      ),
    );
  }
}
