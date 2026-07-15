/// Gộp validator của form Đăng nhập về 1 chỗ - đồng nhất với cách
/// ProductValidators tách validator ra khỏi cả controller lẫn UI (xem
/// product_validators.dart để biết đầy đủ lý do).
class AuthValidators {
  AuthValidators._();

  static String? username(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập tên đăng nhập';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    return null;
  }
}
