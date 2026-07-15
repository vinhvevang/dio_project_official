import 'package:hive/hive.dart';

class TokenStorage {
  static const String _boxName = 'appBox';
  static const String _tokenKey = 'token';
  static const String _usernameKey = 'username';
  static const String _passwordKey = 'password';

  static Box get _box => Hive.box(_boxName);

  static Future<void> saveToken(String token) async {
    await _box.put(_tokenKey, token);
  }

  static String? getToken() {
    final value = _box.get(_tokenKey);
    return value is String ? value : null;
  }

  static Future<void> clearToken() async {
    await _box.delete(_tokenKey);
  }

  static Future<void> saveCredentials({
    required String username,
    required String password,
  }) async {
    await _box.put(_usernameKey, username);
    await _box.put(_passwordKey, password);
  }

  static Map<String, String>? getCredentials() {
    final rawUsername = _box.get(_usernameKey);
    final rawPassword = _box.get(_passwordKey);
    if (rawUsername is! String || rawPassword is! String) return null;
    return {'username': rawUsername, 'password': rawPassword};
  }

  static Future<void> clearCredentials() async {
    await _box.delete(_usernameKey);
    await _box.delete(_passwordKey);
  }

  static Future<void> clearAll() async {
    await _box.clear();
  }
}