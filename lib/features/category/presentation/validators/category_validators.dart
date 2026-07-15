/// Gộp validator của form Danh mục về 1 chỗ - đồng nhất với cách
/// ProductValidators tách validator ra khỏi cả controller lẫn UI (xem
/// product_validators.dart để biết đầy đủ lý do).
class CategoryValidators {
  CategoryValidators._();

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Tên danh mục không được để trống';
    }
    return null;
  }
}
