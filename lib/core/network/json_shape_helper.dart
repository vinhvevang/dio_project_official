/// Các hàm tiện ích diễn giải HÌNH DẠNG dữ liệu JSON mà backend trả về (bóc
/// lớp bọc "data", ép về Map/List an toàn...) - KHÔNG liên quan gì tới việc
/// GỌI MẠNG (đó là việc của tầng datasource, xem base_dio_datasource.dart).
///
/// Trước đây các hàm này nằm chung trong BaseDioRepository cùng với
/// dio/run() - khiến Repository (giờ không còn gọi dio trực tiếp nữa, việc
/// đó đã chuyển hết xuống DataSource) vẫn phải "extends" 1 class có tên ngụ
/// ý là nó tự gọi mạng, dù thực tế không còn đúng. Tách riêng ra mixin này
/// để Repository chỉ lấy đúng phần nó thực sự cần: diễn giải dữ liệu thô mà
/// DataSource đã đưa lên, không kèm theo khả năng gọi mạng nó không dùng tới.
mixin JsonShapeHelper {
  /// Bóc lớp bọc `{"data": ...}` nếu có - hầu hết endpoint của backend này
  /// trả dữ liệu thật nằm trong field "data".
  dynamic unwrapData(dynamic raw) {
    if (raw is Map && raw.containsKey('data')) return raw['data'];
    return raw;
  }

  /// Ép về Map<String, dynamic> an toàn (Map trả từ JSON decode thường là
  /// Map<dynamic, dynamic>) - ném lỗi rõ ràng thay vì để lỗi ép kiểu mơ hồ.
  Map<String, dynamic> asStringKeyedMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    throw Exception('Dữ liệu trả về không đúng định dạng (mong đợi object)');
  }

  /// Ép về danh sách Map - chấp nhận cả trường hợp backend trả về 1 object
  /// đơn lẻ thay vì mảng (tự bọc thành mảng 1 phần tử).
  List<Map<String, dynamic>> asMapList(dynamic raw) {
    if (raw == null) return [];
    final list = raw is List ? raw : [raw];
    return list.whereType<Map>().map(asStringKeyedMap).toList();
  }
}
