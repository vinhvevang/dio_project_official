
class CategoryValidators {
  CategoryValidators._();

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Tên danh mục không được để trống';
    }
    return null;
  }
}
