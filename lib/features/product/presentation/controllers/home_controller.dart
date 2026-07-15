import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio_complete/core/storage/token_storage.dart';
import 'package:dio_complete/core/widgets/confirm_dialog.dart';
import 'package:dio_complete/core/widgets/app_message_dialog.dart';
import 'package:dio_complete/core/widgets/cart_quantity_dialog.dart';
import 'package:dio_complete/core/widgets/flying_cart_overlay.dart';
import 'package:dio_complete/features/product/data/models/product_model.dart';
import 'package:dio_complete/features/cart/domain/usecases/cart_usecase.dart';
import 'package:dio_complete/features/product/domain/usecases/product_usecase.dart';
import 'package:dio_complete/features/product/presentation/controllers/product_detail_args.dart';
import 'package:dio_complete/features/category/presentation/controllers/category_controller.dart';
import 'package:dio_complete/routes/app_routes.dart';

class HomeController extends GetxController {
  final _productUseCase = Get.find<ProductUseCase>();
  final _cartUseCase = Get.find<CartUseCase>();
  final _categoryController = Get.find<CategoryController>();

  // ─── Danh sách sản phẩm ───────────────────────────────────────
  final allProducts = <Product>[].obs;    // tất cả đã tải về
  final shownProducts = <Product>[].obs;  // danh sách hiển thị (sau filter/search)

  // ─── Trạng thái loading ───────────────────────────────────────
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;

  // ─── Giỏ hàng ─────────────────────────────────────────────────
  final cartCount = 0.obs;
  final cartIconKey = GlobalKey();

  /// Cache GlobalKey của nút "thêm vào giỏ" theo id sản phẩm - PHẢI tái dùng
  /// đúng 1 instance qua các lần rebuild item trong danh sách (thay vì tạo
  /// GlobalKey() mới mỗi lần builder chạy) vì GlobalKey cần ổn định để giữ
  /// đúng định danh RenderObject (dùng tính điểm bắt đầu hoạt ảnh bay vào
  /// giỏ) - tạo mới liên tục khiến hoạt ảnh mất điểm gốc/không định danh
  /// đúng phần tử qua các lần rebuild.
  final Map<int, GlobalKey> _addButtonKeys = {};

  GlobalKey addButtonKeyFor(int productId) =>
      _addButtonKeys.putIfAbsent(productId, () => GlobalKey());

  // ─── Tìm kiếm ────────────────────────────────────────────────
  // SearchController (Flutter, kế thừa TextEditingController) để dùng với
  // SearchAnchor.bar - đọc trực tiếp searchController.text lúc lọc thay vì
  // lưu thêm 1 biến "searchText" riêng dễ bị lệch với nội dung ô nhập.
  final searchController = SearchController();

  /// Debounce cho việc lọc theo từng ký tự gõ - không lọc lại NGAY mỗi ký tự
  /// (tốn công lọc toàn bộ allProducts liên tục khi người dùng còn đang gõ
  /// dở), chỉ lọc khi người dùng NGỪNG gõ được [_searchDebounceDuration].
  Timer? _searchDebounce;
  static const _searchDebounceDuration = Duration(milliseconds: 350);

  /// Lịch sử tìm kiếm gần đây (mới nhất ở đầu). Chỉ ghi khi người dùng THẬT
  /// SỰ chốt một lượt tìm kiếm (Enter hoặc chọn gợi ý), không ghi theo từng
  /// ký tự gõ dở.
  static const _maxRecentSearches = 8;
  final recentSearches = <String>[].obs;

  // ─── Lọc theo giá (sort by nearest) ──────────────────────────
  final priceFilterController = TextEditingController();
  final targetPrice = 0.0.obs; // 0 = không lọc

  // ─── Scroll ───────────────────────────────────────────────────
  final scrollController = ScrollController();

  int _page = 1;
  static const _limit = 10;

  @override
  void onInit() {
    super.onInit();
    _loadProducts(reset: true);
    _updateCartCount();

    // Khi cuộn gần cuối → load thêm
    scrollController.addListener(() {
      final pos = scrollController.position;
      if (pos.pixels >= pos.maxScrollExtent - 200) {
        if (!isLoadingMore.value && hasMore.value) {
          _loadProducts();
        }
      }
    });

    // Reactive: đổi targetPrice → cập nhật list ngay (tìm kiếm gọi
    // _applyFilter() trực tiếp qua onSearchChanged, xem bên dưới)
    targetPrice.listen((_) => _applyFilter());
    // Chọn danh mục ở Drawer -> lọc lại danh sách ngay
    _categoryController.selectedCategory.listen((_) => _applyFilter());
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    scrollController.dispose();
    searchController.dispose();
    priceFilterController.dispose();
    super.onClose();
  }

  // ─── Load sản phẩm từ API ─────────────────────────────────────
  Future<void> _loadProducts({bool reset = false}) async {
    if (isLoading.value || isLoadingMore.value) return;

    if (reset) {
      isLoading.value = true;
      _page = 1;
      hasMore.value = true;
    } else {
      isLoadingMore.value = true;
    }

    try {
      final result = await _productUseCase.getProducts(
        page: _page,
        limit: _limit,
      );

      if (reset) {
        allProducts.assignAll(result.products);
      } else {
        allProducts.addAll(result.products);
      }

      hasMore.value = result.products.length == _limit &&
          (result.count == null || allProducts.length < result.count!);
      if (hasMore.value) _page++;

      _applyFilter();
    } catch (e) {
      await showAppMessageDialog(
        title: 'Lỗi',
        message: e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  // ─── Lọc + sắp xếp danh sách hiển thị ────────────────────────
  void _applyFilter() {
    var list = allProducts.toList();

    // 0. Lọc theo danh mục đang chọn ở Drawer (null = "Tất cả")
    final selectedCategory = _categoryController.selectedCategory.value;
    if (selectedCategory != null) {
      list = list.where((p) => p.categoryId == selectedCategory.id).toList();
    }

    // 1. Lọc theo tên
    final query = searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((p) => p.name.toLowerCase().contains(query)).toList();
    }

    // 2. Sắp xếp theo giá gần với targetPrice nhất (nếu có filter)
    if (targetPrice.value > 0) {
      list.sort((a, b) {
        final diffA = (a.price - targetPrice.value).abs();
        final diffB = (b.price - targetPrice.value).abs();
        return diffA.compareTo(diffB); // gần nhất lên đầu
      });
    }

    shownProducts.assignAll(list);
  }

  // ─── Search callback ──────────────────────────────────────────
  /// Gọi mỗi ký tự gõ (SearchAnchor.bar onChanged) - DEBOUNCE lại, không lọc
  /// ngay lập tức để tránh lọc toàn bộ danh sách liên tục khi đang gõ dở.
  void onSearchChanged(String _) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(_searchDebounceDuration, _applyFilter);
  }

  /// Lọc lại NGAY (không debounce) - dùng khi người dùng đã CHỐT xong 1 lượt
  /// tìm kiếm (nhấn Enter, chọn gợi ý hoặc chọn lịch sử) thay vì đang gõ dở,
  /// nên không cần chờ thêm.
  void applySearchImmediately() {
    _searchDebounce?.cancel();
    _applyFilter();
  }

  /// Ghi 1 từ khóa vào lịch sử tìm kiếm gần đây. Chỉ gọi khi người dùng chốt
  /// một lượt tìm kiếm (Enter hoặc chọn gợi ý).
  void commitSearch(String keyword) {
    final trimmed = keyword.trim();
    if (trimmed.isEmpty) return;

    recentSearches.removeWhere((s) => s.toLowerCase() == trimmed.toLowerCase());
    recentSearches.insert(0, trimmed);

    if (recentSearches.length > _maxRecentSearches) {
      recentSearches.removeRange(_maxRecentSearches, recentSearches.length);
    }
  }

  void removeRecentSearch(String term) {
    recentSearches.remove(term);
  }

  // ─── Áp dụng filter giá (từ bottom sheet) ───────────────────
  void applyPriceFilter() {
    final val = double.tryParse(priceFilterController.text.trim()) ?? 0;
    targetPrice.value = val;
    Get.back();
  }

  void clearPriceFilter() {
    priceFilterController.clear();
    targetPrice.value = 0;
  }

  bool get isFilterActive => targetPrice.value > 0;

  // ─── Pull-to-refresh ─────────────────────────────────────────
  @override
  Future<void> refresh() => _loadProducts(reset: true);

  // ─── Giỏ hàng ─────────────────────────────────────────────────
  void _updateCartCount() {
    cartCount.value = _cartUseCase.count;
  }

  Future<void> promptAddToCart(
    BuildContext context,
    Product product,
    GlobalKey addButtonKey,
  ) async {
    final quantity = await showCartQuantityDialog(
      context: context,
      product: product,
      initialQuantity: 1,
    );

    if (quantity == null) return;

    await addToCart(context, product, quantity, addButtonKey);
  }

  Future<void> addToCart(
    BuildContext context,
    Product product,
    int quantity,
    GlobalKey addButtonKey,
  ) async {
    final startRect = _rectFor(addButtonKey);
    final endRect = _rectFor(cartIconKey);

    if (startRect != null && endRect != null) {
      await FlyingCartOverlay.animate(
        context: context,
        from: startRect,
        to: endRect,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: product.image.isNotEmpty
              ? Image.network(product.image, width: 56, height: 56, fit: BoxFit.cover)
              : Container(
                  width: 56,
                  height: 56,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
        ),
      );
    }

    await _cartUseCase.addItem(product, quantity: quantity);
    _updateCartCount();
    await showAppMessageDialog(
      title: 'Đã thêm vào giỏ',
      message: '${product.name} x$quantity',
      isSuccess: true,
    );
  }

  Rect? _rectFor(GlobalKey key) {
    final renderObject = key.currentContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return null;
    final topLeft = renderObject.localToGlobal(Offset.zero);
    return topLeft & renderObject.size;
  }

  // ─── Điều hướng ───────────────────────────────────────────────
  void goToDetail(Product product) async {
    final changed = await Get.toNamed(
      AppRoutes.productDetail,
      arguments: ProductDetailArgs.fromProduct(product),
    );
    if (changed == true) refresh();
  }

  void goToAddProduct() async {
    final created = await Get.toNamed(AppRoutes.productForm);
    if (created is Product) {
      prependProduct(created);
    } else if (created == true) {
      refresh();
    }
  }

  void goToCart() async {
    await Get.toNamed(AppRoutes.cart);
    _updateCartCount();
  }

  // ─── Đăng xuất ────────────────────────────────────────────────
  Future<void> logout() async {
    final confirmed = await showConfirmDialog(
      title: 'Đăng xuất',
      message: 'Bạn có chắc muốn đăng xuất?',
      confirmLabel: 'Đăng xuất',
    );

    if (confirmed) {
      await TokenStorage.clearAll();
      // KHÔNG xóa giỏ hàng ở đây nữa. App chỉ có 1 tài khoản/thiết bị (không
      // có khái niệm nhiều user khác nhau đăng nhập cùng máy), nên giỏ hàng
      // nên tồn tại xuyên suốt các lần đăng nhập - giống cách nó đã tồn tại
      // xuyên suốt việc tắt/mở lại app (Hive lưu trên đĩa, không liên quan gì
      // tới phiên đăng nhập). Muốn xóa giỏ hàng, người dùng đã có sẵn nút
      // "Xóa tất cả" riêng trong màn giỏ hàng (cart_controller.clearCart()).
      Get.offAllNamed(AppRoutes.login);
    }
  }

  void prependProduct(Product product) {
    allProducts.insert(0, product);
    _applyFilter();
  }

  void updateProductInList(Product updatedProduct) {
    final index = allProducts.indexWhere((item) => item.id == updatedProduct.id);
    if (index >= 0) {
      allProducts[index] = updatedProduct;
      _applyFilter();
    }
  }
}
