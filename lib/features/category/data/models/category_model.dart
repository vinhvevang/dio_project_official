/// Model ĐỌC dữ liệu danh mục - đại diện ĐÚNG shape JSON mà backend GET trả
/// về. Chỉ còn field + constructor thuần túy - toàn bộ logic chuyển đổi
/// (fromJson/toEntity) đã chuyển sang CategoryMapper
/// (data/mappers/category_mapper.dart) để 1 nơi duy nhất chứa hết logic
/// "dịch" dữ liệu, Model chỉ còn là khuôn dữ liệu.
///
/// KHÔNG kế thừa (`extends`) entity domain [Category] - Model/Entity là 2
/// class tách biệt, chuyển đổi qua CategoryMapper.toEntity() tường minh thay
/// vì dựa vào quan hệ is-a của kế thừa.
class CategoryModel {
  final int id;
  final int status;
  final String createdAt;
  final String updatedAt;
  final String name;

  const CategoryModel({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
  });
}
