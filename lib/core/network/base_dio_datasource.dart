import 'package:dio/dio.dart';
import 'package:dio_complete/core/network/api_client.dart';
import 'package:dio_complete/core/network/dio_error_mapper.dart';

/// Lớp nền cho tầng DataSource (gọi API thô) - KHÔNG phải cho Repository.
/// Repository giờ không còn tự gọi dio nữa (việc đó thuộc về DataSource),
/// nên chỉ DataSource mới cần extends class này. Nếu Repository cần diễn
/// giải hình dạng JSON, dùng JsonShapeHelper (json_shape_helper.dart) - tách
/// riêng vì đó là mối quan tâm khác (diễn giải dữ liệu, không phải gọi mạng).
abstract class BaseDioDataSource {
  Dio get dio => ApiClient.dio;

  /// Bọc 1 lượt gọi mạng - chuyển DioException thành Exception với thông
  /// điệp thân thiện (dioErrorMessage), thay vì để lỗi mạng thô lộ ra UI.
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
}
