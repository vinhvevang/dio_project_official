/// Model ĐỌC dữ liệu danh mục (những gì backend trả về qua GET). Chiều GHI
/// (tạo/sửa danh mục) dùng [CategoryPayload] (category_payload.dart) - tách
/// riêng cùng lý do với Product/ProductPayload: 2 chiều đọc/ghi không nhất
/// thiết cùng shape, và trước đây toJson() ở đây không được nơi nào gọi tới
/// (repository tự dựng map tay riêng).
class Category {
  final int id;
  final int status;
  final String createdAt;
  final String updatedAt;
  final String name;

  const Category({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      status: json['status'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Category copyWith({
    int? id,
    int? status,
    String? createdAt,
    String? updatedAt,
    String? name,
  }) {
    return Category(
      id: id ?? this.id,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
    );
  }
}
