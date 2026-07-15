import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio_complete/core/widgets/app_formatter.dart';
import 'package:dio_complete/features/product/data/models/product_model.dart';
import 'package:dio_complete/features/product/presentation/controllers/home_controller.dart';

/// Ô tìm kiếm dùng SearchAnchor.bar (Material 3) - bấm vào mở rộng thành
/// overlay. Khi ô đang rỗng, overlay hiện LỊCH SỬ TÌM KIẾM GẦN ĐÂY; khi đã
/// gõ từ khóa, overlay đổi sang gợi ý TÊN SẢN PHẨM khớp từ khóa đó.
///
/// Gõ từng ký tự chỉ DEBOUNCE lọc danh sách chính (qua
/// [HomeController.onSearchChanged]) - còn khi người dùng CHỐT xong 1 lượt
/// tìm kiếm (Enter, chọn gợi ý, chọn lịch sử) thì lọc NGAY qua
/// [HomeController.applySearchImmediately], không chờ debounce nữa.
class ProductSearchBar extends GetView<HomeController> {
  const ProductSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SearchAnchor.bar(
      searchController: controller.searchController,
      barHintText: 'Tìm kiếm theo tên...',
      barLeading: const Icon(Icons.search),
      viewHintText: 'Tìm kiếm theo tên...',
      // SearchAnchor có bug đã biết: gọi closeView() để điền gợi ý không tự
      // kích hoạt lại logic lọc, nên onSearchChanged/commitSearch còn được
      // gọi thủ công ngay trong onTap của từng gợi ý, không chỉ trông vào
      // onChanged.
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
        final matches = controller.allProducts
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
    // Bọc trong Obx để khi bấm "x" xóa 1 mục, chính widget này tự rebuild lại
    // - không phụ thuộc việc SearchAnchor có gọi lại suggestionsBuilder hay
    // không (né bug đã ghi chú ở trên).
    return Obx(() {
      if (controller.recentSearches.isEmpty) {
        return const ListTile(
          leading: Icon(Icons.history),
          title: Text('Chưa có tìm kiếm gần đây'),
        );
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: controller.recentSearches.map((term) {
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
