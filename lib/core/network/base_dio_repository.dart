import 'package:dio/dio.dart';
import 'package:dio_complete/core/network/api_client.dart';
import 'package:dio_complete/core/network/dio_error_mapper.dart';

/// Base cho MỌI repository gọi API qua Dio (Product, Category, Auth...).
///
/// Trước đây mỗi repository tự viết lại y hệt 2 việc:
///   1. try/catch DioException rồi đổi thành Exception với message thân
///      thiện qua [dioErrorMessage] - lặp lại ở gần như MỌI method.
///   2. Bóc lớp bọc `{ "data": ... }` mà backend hay dùng, rồi ép Map/List về
///      đúng kiểu - mỗi repository viết một bản hơi khác nhau.
/// Gộp 2 việc này vào 1 base class dùng chung để mỗi repository chỉ cần lo
/// đúng phần logic riêng của nó.
abstract class BaseDioRepository {
  Dio get dio => ApiClient.dio;

  /// Chạy 1 lời gọi API, tự bắt [DioException] và đổi thành [Exception] với
  /// message thân thiện (qua [dioErrorMessage]). Lỗi khác (không phải từ
  /// Dio, VD lỗi parse dữ liệu) được ném nguyên vẹn để nơi gọi tự xử lý.
  Future<T> run<T>(
    Future<T> Function() request, {
    required String fallbackMessage,
  }) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e, fallbackMessage));
    }
  }

  /// Bóc lớp bọc `{ "data": ... }` mà backend hay dùng - trả về nguyên [raw]
  /// nếu response không có lớp bọc này.
  dynamic unwrapData(dynamic raw) {
    if (raw is Map && raw.containsKey('data')) return raw['data'];
    return raw;
  }

  /// Ép 1 giá trị dynamic (đã biết là Map) về đúng kiểu Map<String, dynamic>.
  Map<String, dynamic> asStringKeyedMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    throw Exception('Dữ liệu trả về không đúng định dạng (mong đợi object)');
  }

  /// Ép 1 giá trị dynamic về List<Map<String, dynamic>>, bỏ qua phần tử nào
  /// không phải Map. [raw] có thể là 1 List, 1 Map đơn lẻ (tự bọc thành list
  /// 1 phần tử để dùng chung logic), hoặc null (trả về list rỗng).
  List<Map<String, dynamic>> asMapList(dynamic raw) {
    if (raw == null) return [];
    final list = raw is List ? raw : [raw];
    return list.whereType<Map>().map(asStringKeyedMap).toList();
  }
}
