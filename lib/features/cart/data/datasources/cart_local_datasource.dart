import 'package:hive/hive.dart';

/// Tầng datasource CỤC BỘ (Hive) - đối xứng với "remote datasource" của các
/// feature gọi API, chỉ khác là lưu trên máy thay vì qua mạng. Chỉ biết
/// đọc/ghi dữ liệu THÔ vào Hive box, không biết gì về CartItem/Product -
/// Repository là nơi diễn giải dữ liệu thô này qua CartItemMapper.
abstract class CartLocalDataSource {
  /// Trả về dữ liệu thô lưu trong box - có thể là null (chưa từng lưu gì),
  /// 1 List, hoặc (bản ghi cũ) 1 String JSON - Repository tự xử lý các dạng
  /// này khi diễn giải.
  dynamic readItems();

  Future<void> writeItems(List<Map<String, dynamic>> items);

  Future<void> clear();
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  static const _boxName = 'cartBox';
  static const _key = 'items';

  Box get _box => Hive.box(_boxName);

  @override
  dynamic readItems() => _box.get(_key);

  @override
  Future<void> writeItems(List<Map<String, dynamic>> items) => _box.put(_key, items);

  @override
  Future<void> clear() => _box.delete(_key);
}
