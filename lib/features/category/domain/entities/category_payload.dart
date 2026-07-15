/// Dữ liệu GHI khi tạo/sửa danh mục - đặt ở domain theo cùng lý do với
/// ProductPayload (xem product_payload.dart), toJson() đặt riêng ở
/// data/mappers/category_payload_mapper.dart.
class CategoryPayload {
  final String name;

  const CategoryPayload({required this.name});
}
