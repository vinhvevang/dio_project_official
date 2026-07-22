import 'package:dio/dio.dart';
import 'package:dio_complete/core/network/dio_error_mapper.dart';
import 'package:dio_complete/core/network/json_shape_helper.dart';
import 'package:dio_complete/features/product/data/datasources/product_remote_datasource.dart';
import 'package:dio_complete/features/product/data/mappers/product_mapper.dart';
import 'package:dio_complete/features/product/domain/entities/product.dart';
import 'package:dio_complete/features/product/domain/entities/product_payload.dart';
import 'package:dio_complete/features/product/domain/entities/product_result.dart';
import 'package:dio_complete/features/product/domain/repositories/product_repository.dart';

/// Repository giờ KHÔNG tự gọi dio nữa - mọi lời gọi mạng đi qua
/// [ProductRemoteDataSource]. Repository chỉ còn 2 việc: (1) diễn giải hình
/// dạng dữ liệu thô mà DataSource trả về (qua JsonShapeHelper) rồi chuyển
/// sang Model/Entity (qua ProductMapper), và (2) các quyết định "nghiệp vụ"
/// khi dữ liệu không như mong đợi (backend chỉ trả id thay vì object đầy
/// đủ, GET chi tiết bị 404 dù sản phẩm tồn tại...).
class ProductRepositoryImpl with JsonShapeHelper implements ProductRepository {
  final ProductRemoteDataSource _dataSource;

  ProductRepositoryImpl(this._dataSource);

  List<Product> _extractProducts(dynamic raw) => asMapList(unwrapData(raw))
      .map(ProductMapper.fromJson)
      .map(ProductMapper.toEntity)
      .toList();

  Map<String, dynamic> _extractSingleProductMap(dynamic raw) {
    final node = unwrapData(raw);
    if (node is List) {
      if (node.isEmpty) {
        throw Exception('Server không trả về dữ liệu sản phẩm');
      }
      return asStringKeyedMap(node.first);
    }
    return asStringKeyedMap(node);
  }

  /// Backend này đôi khi không cho GET chi tiết trực tiếp dù sản phẩm có
  /// tồn tại - dự phòng bằng cách tìm trong danh sách đầy đủ thay vì báo lỗi
  /// ngay. Cũng dùng khi tạo/sửa sản phẩm mà backend chỉ trả về id.
  Future<Product> _findProductById(int id) async {
    final result = await getProducts(page: 1, limit: 1000);
    for (final product in result.products) {
      if (product.id == id) return product;
    }
    throw Exception('Không tìm thấy sản phẩm');
  }

  @override
  Future<ProductResult> getProducts({required int page, int limit = 10}) async {
    final raw = await _dataSource.getProducts(page: page, limit: limit);

    final products = _extractProducts(raw);
    final rawPaging = raw is Map ? raw['paging'] : null;
    final pagingMap =
        rawPaging is Map ? asStringKeyedMap(rawPaging) : const <String, dynamic>{};

    final rawCount = pagingMap['count'];
    final rawPage = pagingMap['page'];
    final rawLimit = pagingMap['limit'];

    return ProductResult(
      products: products,
      page: rawPage is int ? rawPage : page,
      limit: rawLimit is int ? rawLimit : limit,
      count: rawCount is num && rawCount > 0 ? rawCount.toInt() : null,
    );
  }

  @override
  Future<Product> getProductDetail(int id) async {
    try {
      final raw = await _dataSource.getProductDetail(id);
      return ProductMapper.toEntity(
        ProductMapper.fromJson(_extractSingleProductMap(raw)),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return _findProductById(id);
      throw Exception(dioErrorMessage(e, 'Tải chi tiết sản phẩm thất bại'));
    } catch (e) {
      return _findProductById(id);
    }
  }

  @override
  Future<Product> createProduct(ProductPayload payload) async {
    final raw = await _dataSource.createProduct(ProductMapper.toJson(payload));
    final node = unwrapData(raw);

    // Trường hợp thường gặp: backend trả về nguyên object sản phẩm vừa tạo.
    if (node is Map || node is List) {
      return ProductMapper.toEntity(
        ProductMapper.fromJson(_extractSingleProductMap(node)),
      ).copyWith(category: payload.category);
    }

    // Backend chỉ trả về id (số) của sản phẩm vừa tạo, không echo lại object
    // đầy đủ -> gọi lại backend để lấy đúng dữ liệu đã lưu, không tự dựng
    // (fake) 1 Product cục bộ từ input người dùng.
    if (node is num) {
      return getProductDetail(node.toInt());
    }

    throw Exception('Không lấy được dữ liệu sản phẩm vừa tạo');
  }

  @override
  Future<Product> updateProduct(int id, ProductPayload payload) async {
    final raw = await _dataSource.updateProduct(id, ProductMapper.toJson(payload));
    final node = unwrapData(raw);

    if (node is Map || node is List) {
      return ProductMapper.toEntity(
        ProductMapper.fromJson(_extractSingleProductMap(node)),
      ).copyWith(category: payload.category);
    }

    // Backend không echo lại object sản phẩm sau khi sửa -> gọi lại chi tiết
    // để lấy đúng dữ liệu thật (kể cả created_at gốc) từ backend.
    return getProductDetail(id);
  }

  @override
  Future<void> deleteProduct(int id) => _dataSource.deleteProduct(id);

  @override
  Future<void> resetData() => _dataSource.resetData();
}
