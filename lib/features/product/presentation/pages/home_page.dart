import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio_complete/core/widgets/app_colors.dart';
import 'package:dio_complete/core/widgets/app_formatter.dart';
import 'package:dio_complete/features/category/presentation/controllers/category_controller.dart';
import 'package:dio_complete/features/category/presentation/widgets/category_drawer.dart';
import 'package:dio_complete/features/cart/presentation/controllers/cart_controller.dart';
import 'package:dio_complete/features/product/presentation/controllers/home_controller.dart';
import 'package:dio_complete/features/product/presentation/widgets/product_filter_sheet.dart';
import 'package:dio_complete/features/product/presentation/widgets/product_grid_card.dart';
import 'package:dio_complete/features/product/presentation/widgets/product_search_bar.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CategoryDrawer(),
      appBar: const _HomeAppBar(),
      body: const Column(
        children: [
          _SearchAndFilterRow(),
          _ActiveCategoryBanner(),
          _ActivePriceFilterBanner(),
          Expanded(child: _ProductGridView()),
        ],
      ),
      floatingActionButton: const _AddProductFab(),
    );
  }
}

class _HomeAppBar extends GetView<HomeController>
    implements PreferredSizeWidget {
  const _HomeAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Sản phẩm'),
      centerTitle: true,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      actions: const [_CartAction(), _LogoutAction()],
    );
  }
}

class _AddProductFab extends GetView<HomeController> {
  const _AddProductFab();

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: controller.goToAddProduct,
      icon: const Icon(Icons.add),
      label: const Text('Thêm SP'),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    );
  }
}

class _CartAction extends GetView<HomeController> {
  const _CartAction();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          key: controller.cartIconKey,
          icon: const Icon(Icons.shopping_cart_outlined),
          onPressed: controller.goToCart,
          tooltip: 'Giỏ hàng',
        ),
        Obx(() {
          final count = Get.find<CartController>().count;
          if (count <= 0) return const SizedBox.shrink();
          return Positioned(right: 6, top: 6, child: _CountBadge(count: count));
        }),
      ],
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;

  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
      ),
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _LogoutAction extends GetView<HomeController> {
  const _LogoutAction();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.logout),
      onPressed: controller.logout,
      tooltip: 'Đăng xuất',
    );
  }
}

class _SearchAndFilterRow extends StatelessWidget {
  const _SearchAndFilterRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      child: Row(
        children: [
          const Expanded(child: ProductSearchBar()),
          const SizedBox(width: 8),
          _FilterAction(onTap: () => showProductFilterSheet(context)),
        ],
      ),
    );
  }
}

class _FilterAction extends GetView<HomeController> {
  final VoidCallback onTap;

  const _FilterAction({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isActive = controller.isFilterActive;
      return Stack(
        children: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Bộ lọc',
            style: IconButton.styleFrom(
              backgroundColor: isActive ? Colors.blue.shade50 : null,
            ),
            onPressed: onTap,
          ),
          if (isActive)
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      );
    });
  }
}

class _ActiveCategoryBanner extends StatelessWidget {
  const _ActiveCategoryBanner();

  @override
  Widget build(BuildContext context) {
    final categoryController = Get.find<CategoryController>();

    return Obx(() {
      final category = categoryController.selectedCategory.value;
      if (category == null) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
        child: Row(
          children: [
            Icon(
              Icons.category_outlined,
              size: 14,
              color: Colors.blue.shade600,
            ),
            const SizedBox(width: 4),
            Text(
              'Danh mục: ${category.name}',
              style: TextStyle(fontSize: 12, color: Colors.blue.shade600),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => categoryController.selectedCategory.value = null,
              child: const Text(
                'Bỏ lọc',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// Dòng hiện mức giá mục tiêu đang lọc (ẩn hoàn toàn nếu không có filter giá).
class _ActivePriceFilterBanner extends GetView<HomeController> {
  const _ActivePriceFilterBanner();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.isFilterActive) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
        child: Row(
          children: [
            Icon(Icons.filter_alt, size: 14, color: Colors.blue.shade600),
            const SizedBox(width: 4),
            Text(
              'Sắp xếp gần giá: ${AppFormatter.currency(controller.targetPrice.value)}',
              style: TextStyle(fontSize: 12, color: Colors.blue.shade600),
            ),
            const Spacer(),
            GestureDetector(
              onTap: controller.clearPriceFilter,
              child: const Text(
                'Xóa lọc',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _ProductGridView extends GetView<HomeController> {
  const _ProductGridView();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.shownProducts.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.shownProducts.isEmpty) {
        if (controller.isLoadingMore.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return _EmptyProductList(onRefresh: controller.refresh);
      }

      return RefreshIndicator(
        onRefresh: controller.refresh,
        child: CustomScrollView(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                10,
                10,
                10,
                controller.isLoadingMore.value ? 10 : 90,
              ),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final product = controller.shownProducts[index];
                  final addButtonKey = controller.addButtonKeyFor(product.id);

                  return ProductGridCard(
                    product: product,
                    addButtonKey: addButtonKey,
                    onTap: () => controller.goToDetail(product),
                    onAddToCart:
                        () => controller.promptAddToCart(product, addButtonKey),
                  );
                }, childCount: controller.shownProducts.length),
              ),
            ),

            if (controller.isLoadingMore.value)
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 90),
                sliver: SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _EmptyProductList extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const _EmptyProductList({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 8),
                Text(
                  'Không tìm thấy sản phẩm',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
