import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:dio_complete/core/widgets/confirm_dialog.dart';
import 'package:dio_complete/core/widgets/app_message_dialog.dart';
import 'package:dio_complete/features/cart/domain/entities/cart_item.dart';
import 'package:dio_complete/features/cart/domain/usecases/cart_usecase.dart';
import 'package:dio_complete/features/product/domain/entities/product.dart';
import 'package:dio_complete/features/product/domain/usecases/product_usecase.dart';
import 'package:dio_complete/features/product/presentation/controllers/home_controller.dart';
import 'package:dio_complete/features/product/presentation/controllers/product_detail_args.dart';
import 'package:dio_complete/features/cart/presentation/controllers/cart_controller.dart';
import 'package:dio_complete/routes/app_routes.dart';

class ProductDetailController extends GetxController {
  final _useCase = Get.find<ProductUseCase>();
  final _cartUseCase = Get.find<CartUseCase>();

  final product = Rxn<Product>(); // null khi đang load
  final isLoading = false.obs;
  final cartQuantity = 0.obs;

  late int _productId;

  /// HomeController/CartController KHÔNG hoist thành field như _useCase ở
  /// trên, vì 2 controller đó chỉ sống khi Home/Cart đang có trong stack
  /// (không đăng ký global như ProductUseCase/CartUseCase) - hoist thẳng
  /// bằng Get.find sẽ crash ngay lúc khởi tạo ProductDetailController nếu lỡ
  /// có luồng nào đó mở thẳng màn Chi tiết mà chưa từng qua Home. Getter này
  /// gom logic kiểm tra "đang sống hay không" về đúng 1 chỗ thay vì lặp lại
  /// Get.isRegistered/Get.find rải rác trong từng hàm.
  HomeController? get _homeControllerIfAlive =>
      Get.isRegistered<HomeController>() ? Get.find<HomeController>() : null;

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments;
    if (arguments is ProductDetailArgs) {
      _productId = arguments.productId;
      product.value = arguments.cachedProduct;
    } else if (arguments is int) {
      _productId = arguments;
    } else {
      _productId = 0;
    }
    _fetchDetail();
    _loadCartQuantity();
  }

  // ─── Tải chi tiết sản phẩm từ API ────────────────────────────
  Future<void> _fetchDetail() async {
    isLoading.value = true;
    try {
      product.value = await _useCase.getProductDetail(_productId);
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('=== LỖI CHI TIẾT SP ===\n$e\n$st');
      }
      await showAppMessageDialog(
        title: 'Lỗi',
        message: e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _loadCartQuantity() {
    final items = _cartUseCase.loadItems();
    final item = items.cast<CartItem?>().firstWhere(
      (entry) => entry?.product.id == _productId,
      orElse: () => null,
    );
    cartQuantity.value = item?.quantity ?? 0;
  }

  // ─── Sang màn edit, truyền Product hiện tại vào form ─────────
  void goToEdit() async {
    final updated = await Get.toNamed(
      AppRoutes.productForm,
      arguments: product.value, // form nhận Product này để điền sẵn
    );

    if (updated is Product) {
      product.value = updated;
      _homeControllerIfAlive?.updateProductInList(updated);
      await _syncCartAfterProductChanged(edited: updated);
    } else if (updated == true) {
      // Reload lại thông tin sau khi sửa
      await _fetchDetail();
    }
  }

  // ─── Xóa sản phẩm (có dialog xác nhận) ───────────────────────
  Future<void> deleteProduct() async {
    final confirmed = await showConfirmDialog(
      title: 'Xóa sản phẩm',
      message: 'Xóa "${product.value?.name}"?\nThao tác này không thể hoàn tác.',
      confirmLabel: 'Xóa',
    );

    if (!confirmed) return;

    isLoading.value = true;
    try {
      await _useCase.deleteProduct(_productId);

      // Sản phẩm vừa bị xóa hẳn -> nếu đang có trong giỏ hàng thì phải xóa
      // luôn ở đó, không thì giỏ hàng còn giữ 1 sản phẩm không còn tồn tại
      // (bấm vào sẽ lỗi, hoặc vẫn "thanh toán" được thứ đã bị xóa).
      await _syncCartAfterProductChanged(deletedId: _productId);

      // Quay về list, báo list tự reload
      Get.back(result: true);
      await showAppMessageDialog(
        title: 'Thành công',
        message: 'Đã xóa sản phẩm',
        isSuccess: true,
      );
    } catch (e) {
      await showAppMessageDialog(
        title: 'Lỗi',
        message: e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Đồng bộ lại giỏ hàng sau khi sản phẩm bị SỬA ([edited]) hoặc XÓA HẲN
  /// ([deletedId]) ở màn chi tiết - giỏ hàng lưu 1 bản snapshot Product riêng
  /// (Hive) nên không tự làm mới theo. Gộp logic này về 1 chỗ vì trước đây
  /// goToEdit() và deleteProduct() mỗi hàm tự lặp lại y hệt kiểu rẽ nhánh
  /// "CartController đang sống thì gọi qua nó, không thì ghi thẳng qua
  /// usecase".
  ///
  /// Luôn truyền ĐÚNG 1 trong 2 tham số. Ưu tiên gọi qua CartController (nếu
  /// đang sống - tức người dùng đã từng mở giỏ hàng trong phiên này) để danh
  /// sách ĐANG HIỂN THỊ được làm mới ngay; nếu chưa, ghi thẳng qua
  /// _cartUseCase (luôn tồn tại, đăng ký global) để dữ liệu Hive đúng ngay từ
  /// bây giờ - không thì lần đầu mở giỏ hàng sau đó vẫn đọc ra bản cũ.
  Future<void> _syncCartAfterProductChanged({
    Product? edited,
    int? deletedId,
  }) async {
    assert(
      (edited == null) != (deletedId == null),
      'Chỉ truyền đúng 1 trong 2: edited hoặc deletedId',
    );

    if (Get.isRegistered<CartController>()) {
      final cart = Get.find<CartController>();
      if (edited != null) {
        await cart.updateProductInList(edited);
      } else {
        await cart.removeProductFromList(deletedId!);
      }
      return;
    }

    if (edited != null) {
      await _cartUseCase.updateProduct(edited);
    } else {
      await _cartUseCase.removeItem(deletedId!);
    }
  }
}
