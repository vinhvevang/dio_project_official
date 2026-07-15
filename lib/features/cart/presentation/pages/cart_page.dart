import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio_complete/core/widgets/app_colors.dart';
import 'package:dio_complete/core/widgets/app_formatter.dart';
import 'package:dio_complete/features/cart/presentation/controllers/cart_controller.dart';
import 'package:dio_complete/features/cart/presentation/widgets/cart_item_tile.dart';

class CartPage extends GetView<CartController> {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: const [_ClearCartAction()],
      ),
      body: const _CartBody(),
    );
  }
}

class _ClearCartAction extends GetView<CartController> {
  const _ClearCartAction();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.items.isEmpty) return const SizedBox.shrink();
      return IconButton(
        icon: const Icon(Icons.delete_sweep_outlined),
        tooltip: 'Xóa tất cả',
        onPressed: controller.clearCart,
      );
    });
  }
}

class _CartBody extends GetView<CartController> {
  const _CartBody();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.items.isEmpty) return const _EmptyCart();

      return Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              itemCount: controller.items.length,
              itemBuilder: (context, index) {
                final item = controller.items[index];
                return CartItemTile(
                  key: ValueKey(item.product.id),
                  item: item,
                  onTap: () => controller.goToDetail(item),
                  onIncrease: () => controller.increaseQuantity(item.product.id),
                  onDecrease: () => controller.requestDecreaseQuantity(item.product.id),
                  onRemove: () => controller.removeItem(item.product.id),
                );
              },
            ),
          ),
          const _CartSummaryBar(),
        ],
      );
    });
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          const Text('Giỏ hàng trống', style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 8),
          const Text(
            'Thêm sản phẩm từ trang chủ',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

/// Thanh tổng tiền cố định dưới đáy màn hình.
///
/// Widget này là `const` (được Flutter tái sử dụng nguyên trạng khi
/// _CartBody rebuild), nên PHẢI tự bọc Obx bên trong để vẫn cập nhật đúng
/// tổng tiền/số lượng mỗi khi giỏ hàng đổi - nếu đọc totalQuantity/totalPrice
/// trực tiếp mà không có Obx riêng, nội dung sẽ bị "đóng băng" ở lần build
/// đầu tiên vì Flutter thấy widget const giống hệt lần trước nên bỏ qua,
/// không gọi lại build().
class _CartSummaryBar extends GetView<CartController> {
  const _CartSummaryBar();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${controller.totalQuantity} sản phẩm',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  'Tổng: ${AppFormatter.currency(controller.totalPrice)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
