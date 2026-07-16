import 'package:dio_complete/features/product/domain/entities/product.dart';


class ProductDetailArgs {
  /// Id sản phẩm cần tải chi tiết - luôn cần, kể cả khi đã có [cachedProduct].
  final int productId;

 
  final Product? cachedProduct;

  const ProductDetailArgs({required this.productId, this.cachedProduct});


  factory ProductDetailArgs.fromProduct(Product product) =>
      ProductDetailArgs(productId: product.id, cachedProduct: product);
}
