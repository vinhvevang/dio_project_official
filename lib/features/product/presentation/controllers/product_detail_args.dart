import 'package:dio_complete/features/product/domain/entities/product.dart';

/// Argument điều hướng sang màn Chi tiết sản phẩm.
///
/// Trước đây có 2 cách gọi khác nhau tới cùng 1 màn: HomeController truyền
/// thẳng 1 `Product`, còn CartController lại truyền 1 `Map` dạng
/// `{'product': ..., 'quantity': ...}` (key 'quantity' thực ra không nơi nào
/// đọc tới - dữ liệu chết). ProductDetailController vì vậy phải tự đoán kiểu
/// bằng chuỗi if (arguments is Product) / else if (arguments is Map) / else,
/// vừa rườm rà vừa phải ép kiểu thủ công. Gộp lại thành đúng 1 kiểu duy nhất,
/// dùng ở MỌI nơi điều hướng tới màn này.
class ProductDetailArgs {
  /// Id sản phẩm cần tải chi tiết - luôn cần, kể cả khi đã có [cachedProduct].
  final int productId;

  /// Bản Product đã có sẵn (từ danh sách/giỏ hàng) để hiển thị NGAY trong lúc
  /// chờ gọi API lấy chi tiết mới nhất - null thì màn chi tiết tự hiện loading
  /// cho tới khi tải xong.
  final Product? cachedProduct;

  const ProductDetailArgs({required this.productId, this.cachedProduct});

  /// Tiện tạo từ 1 Product đã có sẵn (trường hợp phổ biến nhất: mở chi tiết
  /// từ danh sách sản phẩm hoặc từ giỏ hàng).
  factory ProductDetailArgs.fromProduct(Product product) =>
      ProductDetailArgs(productId: product.id, cachedProduct: product);
}
