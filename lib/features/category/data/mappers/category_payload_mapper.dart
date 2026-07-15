import 'package:dio_complete/features/category/domain/entities/category_payload.dart';

/// Biến [CategoryPayload] (domain, không biết JSON) thành Map để gửi lên
/// API. Xem product_payload_mapper.dart để biết đầy đủ lý do tách lớp này
/// khỏi domain.
extension CategoryPayloadMapper on CategoryPayload {
  Map<String, dynamic> toJson() => {'name': name};
}
