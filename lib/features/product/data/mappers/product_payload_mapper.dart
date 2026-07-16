import 'package:dio_complete/features/product/domain/entities/product_payload.dart';
extension ProductPayloadMapper on ProductPayload {
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'price': price,
      'stock': stock,
      'description': description,
      'image': image.isEmpty ? null : image,
      'category_id': category.id,
    };
  }
}
