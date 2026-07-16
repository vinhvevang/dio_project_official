import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';


String dioErrorMessage(DioException e, String fallback) {
  final data = e.response?.data;
  final status = e.response?.statusCode;
 
  if (kDebugMode) {
    debugPrint('DioException status=$status data=$data');
  }

  if (data is Map && data['message'] != null) {
    return data['message'].toString();
  }
  if (data is Map && data['error'] != null) {
    return data['error'].toString();
  }
  if (data is List && data.isNotEmpty) {
    return data.first.toString();
  }
  if (data is String && data.trim().isNotEmpty) {
    return data;
  }
  if (status != null) {
    return '$fallback (HTTP $status)';
  }
  return fallback;
}
