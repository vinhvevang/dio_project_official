import 'package:dio/dio.dart';
import 'package:dio_complete/core/network/api_client.dart';
import 'package:dio_complete/core/network/dio_error_mapper.dart';


abstract class BaseDioRepository {
  Dio get dio => ApiClient.dio;


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


  dynamic unwrapData(dynamic raw) {
    if (raw is Map && raw.containsKey('data')) return raw['data'];
    return raw;
  }

  Map<String, dynamic> asStringKeyedMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    throw Exception('Dữ liệu trả về không đúng định dạng (mong đợi object)');
  }


  List<Map<String, dynamic>> asMapList(dynamic raw) {
    if (raw == null) return [];
    final list = raw is List ? raw : [raw];
    return list.whereType<Map>().map(asStringKeyedMap).toList();
  }
}
