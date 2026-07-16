/// Định dạng số/tiền dùng chung cho toàn app.
class AppFormatter {
  AppFormatter._();

  
  static String currency(num value, {bool withSuffix = true}) {
    final rounded = value.round();
    final isNegative = rounded < 0;
    final digits = rounded.abs().toString();

    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      final positionFromEnd = digits.length - i;
      buffer.write(digits[i]);
      // Chèn dấu chấm sau mỗi 3 chữ số, trừ chữ số cuối cùng.
      if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
        buffer.write('.');
      }
    }

    final formatted = '${isNegative ? '-' : ''}$buffer';
    return withSuffix ? '$formatted đ' : formatted;
  }
}
