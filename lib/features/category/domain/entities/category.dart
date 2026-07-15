/// Entity DOMAIN của danh mục - object nghiệp vụ thuần, không biết gì về
/// JSON/HTTP. Xem product.dart để biết đầy đủ lý do tách entity khỏi model.
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
