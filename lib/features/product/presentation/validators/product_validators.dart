import 'package:dio_complete/features/category/domain/entities/category.dart';

/// Gộp toàn bộ validator của form Sản phẩm về 1 chỗ.
///
/// Trước đây `validateCategory` nằm trong ProductFormController trong khi
/// validator của các field còn lại (tên, mã, giá, số lượng, URL ảnh) lại viết
/// trực tiếp dạng lambda ngay trong product_form_page.dart - không đồng bộ
/// (không rõ quy ước validator nên nằm ở đâu), khó tìm khi cần sửa, và khó
/// test độc lập với UI/controller. Gộp về đây, dùng chung cho cả 2 nơi.
class ProductValidators {
  ProductValidators._();

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Tên không được để trống';
    }
    return null;
  }

  static String? code(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mã không được để trống';
    }
    return null;
  }

  static String? price(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Giá không được để trống';
    }
    final parsed = int.tryParse(value.trim());
    if (parsed == null) return 'Giá phải là số nguyên';
    if (parsed < 0) return 'Giá không được âm';
    return null;
  }

  static String? stock(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Số lượng không được để trống';
    }
    final parsed = int.tryParse(value.trim());
    if (parsed == null) return 'Số lượng phải là số nguyên';
    if (parsed < 0) return 'Số lượng không được âm';
    return null;
  }

  /// URL ảnh là field không bắt buộc - để trống vẫn hợp lệ.
  static String? image(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return null;
    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme) return 'URL không hợp lệ';
    return null;
  }

  static String? category(Category? value) {
    return value == null ? 'Vui lòng chọn danh mục' : null;
  }
}
