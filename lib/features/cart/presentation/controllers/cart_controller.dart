import 'package:get/get.dart';
import 'package:dio_complete/core/widgets/confirm_dialog.dart';
import 'package:dio_complete/features/cart/domain/entities/cart_item.dart';
import 'package:dio_complete/features/cart/domain/usecases/cart_usecase.dart';
import 'package:dio_complete/features/product/domain/entities/product.dart';
import 'package:dio_complete/features/product/presentation/controllers/product_detail_args.dart';
import 'package:dio_complete/routes/app_routes.dart';

class CartController extends GetxController {
  final _cartUseCase = Get.find<CartUseCase>();

  final items = <CartItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadCart();
  }

  void _loadCart() {
    items.assignAll(_cartUseCase.loadItems());
  }

  /// Thêm sản phẩm vào giỏ - gọi từ HomeController khi người dùng bấm "thêm
  /// vào giỏ" ở màn danh sách. Trước đây Home ghi thẳng qua CartUseCase,
  /// không đụng gì tới `items` ở đây cả - nếu CartController đã từng được
  /// tạo trong phiên này (người dùng đã mở giỏ hàng ít nhất 1 lần), `items`
  /// sẽ bị LỆCH với dữ liệu thật cho tới lần load lại tiếp theo. Giờ luôn đi
  /// qua đây để `items` (nguồn duy nhất cho badge số lượng giỏ hàng ở Home)
  /// luôn đúng ngay lập tức.
  Future<void> addProduct(Product product, {int quantity = 1}) async {
    await _cartUseCase.addItem(product, quantity: quantity);
    _loadCart();
  }

  // Tổng tiền giỏ hàng
  double get totalPrice => items.fold(0, (sum, item) => sum + item.product.price * item.quantity);

  // Số loại sản phẩm (số dòng trong giỏ, không phải tổng số lượng cộng dồn) -
  // đặt tên khớp với CartRepositoryImpl.count cho nhất quán giữa các layer.
  // (itemCount cũ bị xóa vì là 1 getter y hệt, không nơi nào gọi tới.)
  int get count => items.length;
  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);

  int _quantityFor(int productId) {
    final item = items.cast<CartItem?>().firstWhere(
      (entry) => entry?.product.id == productId,
      orElse: () => null,
    );
    return item?.quantity ?? 0;
  }

  // Xóa 1 sản phẩm khỏi giỏ
  Future<void> removeItem(int productId) async {
    final confirmed = await showConfirmDialog(
      title: 'Xóa khỏi giỏ',
      message: 'Bạn có muốn xóa sản phẩm này khỏi giỏ hàng?',
      confirmLabel: 'Xóa',
    );

    if (!confirmed) return;

    await _cartUseCase.removeItem(productId);
    _loadCart();
  }

  Future<void> increaseQuantity(int productId) async {
    await _cartUseCase.increaseQuantity(productId);
    _loadCart();
  }

  Future<void> requestDecreaseQuantity(int productId) async {
    final quantity = _quantityFor(productId);
    if (quantity <= 1) {
      final confirmed = await showConfirmDialog(
        title: 'Bỏ sản phẩm khỏi giỏ',
        message: 'Bạn có chắc muốn bỏ sản phẩm này khỏi giỏ hàng?',
        confirmLabel: 'Đồng ý',
        cancelLabel: 'Không',
      );

      if (!confirmed) return;
    }

    await decreaseQuantity(productId);
  }

  Future<void> decreaseQuantity(int productId) async {
    await _cartUseCase.decreaseQuantity(productId);
    _loadCart();
  }

  void goToDetail(CartItem item) {
    // Dùng chung đúng 1 kiểu argument với HomeController.goToDetail thay vì 1
    // Map riêng như trước (Map đó còn nhét cả 'quantity' - dữ liệu không nơi
    // nào đọc tới, vì màn chi tiết tự tính lại số lượng trong giỏ qua
    // _loadCartQuantity()).
    Get.toNamed(
      AppRoutes.productDetail,
      arguments: ProductDetailArgs.fromProduct(item.product),
    );
  }

  // Xóa toàn bộ giỏ
  Future<void> clearCart() async {
    final confirmed = await showConfirmDialog(
      title: 'Xóa tất cả',
      message: 'Xóa tất cả sản phẩm trong giỏ hàng?',
      confirmLabel: 'Xóa hết',
    );

    if (!confirmed) return;

    await _cartUseCase.clearAll();
    _loadCart();
  }

  /// Đồng bộ lại thông tin sản phẩm trong giỏ khi nó vừa được sửa ở nơi khác
  /// (trang chi tiết) - nếu không, giỏ hàng sẽ tiếp tục hiện tên/giá cũ vì
  /// nó lưu 1 bản snapshot Product riêng, không tự động làm mới.
  Future<void> updateProductInList(Product updated) async {
    await _cartUseCase.updateProduct(updated);
    _loadCart();
  }

  /// Xóa 1 sản phẩm khỏi giỏ vì nó VỪA BỊ XÓA HẲN ở nơi khác (trang chi
  /// tiết) - KHÔNG hỏi xác nhận lại, khác với removeItem() ở trên (người
  /// dùng đã xác nhận xóa sản phẩm rồi, hỏi thêm 1 lần nữa cho việc xóa khỏi
  /// giỏ là dư thừa/khó hiểu).
  Future<void> removeProductFromList(int productId) async {
    await _cartUseCase.removeItem(productId);
    _loadCart();
  }
}
