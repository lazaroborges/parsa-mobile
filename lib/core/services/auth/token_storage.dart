import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for securely storing and managing JWT tokens
class TokenStorage {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';
  static const _userKey = 'user_data';

  // Singleton pattern
  static final TokenStorage _instance = TokenStorage._internal();
  factory TokenStorage() => _instance;
  TokenStorage._internal();

  /// Save the JWT token securely
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Get the stored JWT token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Delete the stored JWT token
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Save user data securely
  Future<void> saveUserData(String userData) async {
    await _storage.write(key: _userKey, value: userData);
  }

  /// Get stored user data
  Future<String?> getUserData() async {
    return await _storage.read(key: _userKey);
  }

  /// Delete stored user data
  Future<void> deleteUserData() async {
    await _storage.delete(key: _userKey);
  }

  /// Clear all stored authentication data
  Future<void> clearAll() async {
    await deleteToken();
    await deleteUserData();
  }
}
