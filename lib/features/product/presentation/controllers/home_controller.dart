import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio_complete/core/storage/token_storage.dart';
import 'package:dio_complete/core/widgets/confirm_dialog.dart';
import 'package:dio_complete/core/widgets/app_message_dialog.dart';
import 'package:dio_complete/core/widgets/cart_quantity_dialog.dart';
import 'package:dio_complete/core/widgets/flying_cart_overlay.dart';
import 'package:dio_complete/features/product/domain/entities/product.dart';
import 'package:dio_complete/features/cart/domain/usecases/cart_usecase.dart';
import 'package:dio_complete/features/cart/presentation/controllers/cart_controller.dart';
import 'package:dio_complete/features/product/domain/usecases/product_usecase.dart';
import 'package:dio_complete/features/product/presentation/controllers/product_detail_args.dart';
import 'package:dio_complete/features/category/presentation/controllers/category_controller.dart';
import 'package:dio_complete/routes/app_routes.dart';

class HomeController extends GetxController {
  final _productUseCase = Get.find<ProductUseCase>();
  final _cartUseCase = Get.find<CartUseCase>();
  final _categoryController = Get.find<CategoryController>();

  // ─── Danh sách sản phẩm ───────────────────────────────────────
  final allProducts = <Product>[].obs; // tất cả đã tải về
  final shownProducts =
      <Product>[].obs; // danh sách hiển thị (sau filter/search)

  // ─── Trạng thái loading ───────────────────────────────────────
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;

  // ─── Giỏ hàng ─────────────────────────────────────────────────

  final cartIconKey = GlobalKey();

  final Map<int, GlobalKey> _addButtonKeys = {};

  GlobalKey addButtonKeyFor(int productId) =>
      _addButtonKeys.putIfAbsent(productId, () => GlobalKey());

  // ─── Tìm kiếm ────────────────────────────────────────────────

  final searchController = SearchController();

  Timer? _searchDebounce;
  static const _searchDebounceDuration = Duration(milliseconds: 350);

  static const _maxRecentSearches = 8;
  final recentSearches = <String>[].obs;

  // ─── Lọc theo giá (sort by nearest) ──────────────────────────
  final priceFilterController = TextEditingController();
  final targetPrice = 0.0.obs; // 0 = không lọc

  // ─── Scroll ───────────────────────────────────────────────────
  final scrollController = ScrollController();

  // Subscription của 2 listener bên dưới - PHẢI cancel ở onClose(), xem lý do
  // ở onClose().
  StreamSubscription? _targetPriceSubscription;
  StreamSubscription? _categorySubscription;

  int _page = 1;
  static const _limit = 10;

  @override
  void onInit() {
    super.onInit();
    _loadProducts(reset: true);

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
    _targetPriceSubscription = targetPrice.listen((_) => _applyFilter());
    // Chọn danh mục ở Drawer -> lọc lại danh sách ngay
    _categorySubscription = _categoryController.selectedCategory.listen(
      (_) => _applyFilter(),
    );
  }

  @override
  void onClose() {
    _targetPriceSubscription?.cancel();
    _categorySubscription?.cancel();
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

      hasMore.value =
          result.products.length == _limit &&
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

    final isFiltering = selectedCategory != null || query.isNotEmpty;
    if (isFiltering &&
        list.isEmpty &&
        hasMore.value &&
        !isLoading.value &&
        !isLoadingMore.value) {
      _loadProducts();
    }
  }

  // ─── Search callback ──────────────────────────────────────────

  void onSearchChanged(String _) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(_searchDebounceDuration, _applyFilter);
  }

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

  // ─── Áp dụng filter giá (từ bottom sheet) 
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

  // ─── Pull-to-refresh 
  @override
  Future<void> refresh() => _loadProducts(reset: true);

  // ─── Giỏ hàng 

  Future<void> promptAddToCart(Product product, GlobalKey addButtonKey) async {
    final quantity = await showCartQuantityDialog(
      product: product,
      initialQuantity: 1,
    );

    if (quantity == null) return;

    await addToCart(product, quantity, addButtonKey);
  }

  Future<void> addToCart(
    Product product,
    int quantity,
    GlobalKey addButtonKey,
  ) async {
    final startRect = _rectFor(addButtonKey);
    final endRect = _rectFor(cartIconKey);

    if (startRect != null && endRect != null) {
      await FlyingCartOverlay.animate(
        from: startRect,
        to: endRect,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child:
              product.image.isNotEmpty
                  ? Image.network(
                    product.image,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  )
                  : Container(
                    width: 56,
                    height: 56,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
        ),
      );
    }

    if (Get.isRegistered<CartController>()) {
      await Get.find<CartController>().addProduct(product, quantity: quantity);
    } else {
      await _cartUseCase.addItem(product, quantity: quantity);
    }

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

  void goToCart() {
    Get.toNamed(AppRoutes.cart);
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

      Get.offAllNamed(AppRoutes.login);
    }
  }

  void prependProduct(Product product) {
    allProducts.insert(0, product);
    _applyFilter();
  }

  void updateProductInList(Product updatedProduct) {
    final index = allProducts.indexWhere(
      (item) => item.id == updatedProduct.id,
    );
    if (index >= 0) {
      allProducts[index] = updatedProduct;
      _applyFilter();
    }
  }
}
