import 'package:dio_complete/features/product/domain/entities/product_payload.dart';

/// Biến [ProductPayload] (domain, không biết JSON) thành Map để gửi lên API.
/// Đặt ở data layer (không phải domain) vì "shape JSON cụ thể" (dùng
/// category_id dạng số) là chi tiết giao tiếp với backend, domain không cần
/// và không nên biết.
extension ProductPayloadMapper on ProductPayload {
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'price': price,
      'stock': stock,
      'description': description,
      // Gửi null khi người dùng để trống URL ảnh, KHÔNG gửi chuỗi rỗng ''.
      // Rỗng và null đều là "không có ảnh" ở phía app, nhưng 1 số backend xử
      // lý 2 giá trị này khác nhau (VD tự gán ảnh mặc định khi thấy field là
      // rỗng '' nhưng giữ đúng "không có" khi field là null/không gửi lên) -
      // gửi null để rõ ràng là "không có ảnh", không phải "có nhưng để trống".
      'image': image.isEmpty ? null : image,
      // Ghi (POST/PUT) dùng category_id (số) - khác với đọc (GET) trả về
      // object "category" lồng đầy đủ. Xác nhận từ dữ liệu JSON thật lấy về:
      // sản phẩm đã gán danh mục qua field này thành công ở backend.
      'category_id': category.id,
    };
  }
}
