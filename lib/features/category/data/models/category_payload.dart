/// Dữ liệu GHI khi tạo/sửa danh mục (POST /categories, PUT /categories/:id).
/// Tách khỏi [Category] (model ĐỌC) theo cùng nguyên tắc với
/// Product/ProductPayload - xem product_payload.dart để biết lý do đầy đủ.
class CategoryPayload {
  final String name;

  const CategoryPayload({required this.name});

  Map<String, dynamic> toJson() => {'name': name};
}
