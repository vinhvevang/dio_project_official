import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio_complete/core/widgets/app_formatter.dart';
import 'package:dio_complete/features/product/domain/entities/product.dart';
import 'package:dio_complete/features/product/presentation/controllers/home_controller.dart';

class ProductSearchBar extends GetView<HomeController> {
  const ProductSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SearchAnchor.bar(
      searchController: controller.searchController,
      barHintText: 'Tìm kiếm theo tên...',
      barLeading: const Icon(Icons.search),
      viewHintText: 'Tìm kiếm theo tên...',

      onChanged: controller.onSearchChanged,
      onSubmitted: (value) {
        controller.searchController.closeView(value);
        controller.applySearchImmediately();
        controller.commitSearch(value);
      },
      suggestionsBuilder: (context, searchController) {
        final query = searchController.text.trim().toLowerCase();

        // Ô đang rỗng (vừa bấm vào, chưa gõ gì) -> hiện lịch sử tìm kiếm gần
        // đây thay vì gợi ý sản phẩm.
        if (query.isEmpty) {
          return [_RecentSearchesList(searchController: searchController)];
        }

        // Đã có từ khóa -> hiện gợi ý tên sản phẩm khớp.
        final matches =
            controller.allProducts
                .where((p) => p.name.toLowerCase().contains(query))
                .take(6)
                .toList();

        if (matches.isEmpty) {
          return const [
            ListTile(
              leading: Icon(Icons.search_off),
              title: Text('Không có sản phẩm phù hợp'),
            ),
          ];
        }

        return matches.map((Product p) {
          return ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: Text(p.name),
            subtitle: Text(AppFormatter.currency(p.price)),
            onTap: () {
              searchController.closeView(p.name);
              controller.applySearchImmediately();
              controller.commitSearch(p.name);
            },
          );
        }).toList();
      },
    );
  }
}

class _RecentSearchesList extends GetView<HomeController> {
  final SearchController searchController;

  const _RecentSearchesList({required this.searchController});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.recentSearches.isEmpty) {
        return const ListTile(
          leading: Icon(Icons.history),
          title: Text('Chưa có tìm kiếm gần đây'),
        );
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children:
            controller.recentSearches.map((term) {
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(term),
                trailing: IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  tooltip: 'Xóa khỏi lịch sử',
                  onPressed: () => controller.removeRecentSearch(term),
                ),
                onTap: () {
                  searchController.closeView(term);
                  controller.applySearchImmediately();
                  controller.commitSearch(term);
                },
              );
            }).toList(),
      );
    });
  }
}
