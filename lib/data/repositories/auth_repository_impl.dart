import 'package:dio_complete/data/services/auth_service.dart';
import 'package:dio_complete/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _service = AuthService();

  @override
  Future<String> login({required String username, required String password}) {
    return _service.login(username: username, password: password);
  }
}