import 'package:dio_complete/features/category/data/models/category_model.dart';

/// Dữ liệu GHI khi tạo/sửa sản phẩm (POST /products, PUT /products/:id).
///
/// Tách riêng khỏi [Product] (model ĐỌC) vì backend nhận "category_id"
/// (số) ở chiều ghi, khác hẳn "category" (object lồng đầy đủ) mà nó trả về
/// ở chiều đọc - dùng chung 1 class cho cả 2 chiều sẽ phải giữ 1 toJson()
/// không khớp với fromJson() và không nơi nào thực sự gọi tới (chỉ tạo map
/// tay riêng ở repository, dễ lệch field mỗi khi thêm/sửa field sản phẩm).
class ProductPayload {
  final String name;
  final String code;
  final double price;
  final int stock;
  final String description;
  final String image;
  final Category category;

  const ProductPayload({
    required this.name,
    required this.code,
    required this.price,
    required this.stock,
    required this.description,
    required this.image,
    required this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'price': price,
      'stock': stock,
      'description': description,
      'image': image,
      // Ghi (POST/PUT) dùng category_id (số) - khác với đọc (GET) trả về
      // object "category" lồng đầy đủ. Xác nhận từ dữ liệu JSON thật lấy về:
      // sản phẩm đã gán danh mục qua field này thành công ở backend.
      'category_id': category.id,
    };
  }
}
