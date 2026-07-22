import 'package:dio_complete/features/login/data/datasources/auth_remote_datasource.dart';
import 'package:dio_complete/features/login/domain/repositories/auth_repository.dart';

/// Repository ở đây chỉ còn là lớp ủy quyền mỏng xuống AuthRemoteDataSource -
/// không có Model/Entity cần chuyển đổi (đăng nhập chỉ trả về 1 token
/// String), nên không có logic "nghiệp vụ" nào cần thêm ở tầng này.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Future<String> login({required String username, required String password}) {
    return _dataSource.login(username: username, password: password);
  }
}
