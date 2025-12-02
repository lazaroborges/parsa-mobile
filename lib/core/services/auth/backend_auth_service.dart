import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:parsa/core/services/auth/token_storage.dart';
import 'package:parsa/core/services/session_service.dart';
import 'package:parsa/main.dart';

/// Model for authentication response
class AuthResponse {
  final String token;
  final Map<String, dynamic> user;

  AuthResponse({
    required this.token,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      user: json['user'] as Map<String, dynamic>,
    );
  }
}

/// Backend authentication service for Parsa Go API
class BackendAuthService extends ChangeNotifier {
  final TokenStorage _tokenStorage = TokenStorage();
  String? _currentToken;
  Map<String, dynamic>? _currentUser;


  static final BackendAuthService _instance = BackendAuthService._internal();
  static BackendAuthService get instance => _instance;

  BackendAuthService._internal();

  // For provider compatibility, expose the singleton
  factory BackendAuthService() => _instance;

  String? get token => _currentToken;
  Map<String, dynamic>? get user => _currentUser;
  bool get isLoggedIn => _currentToken != null;

  /// Email/Password Login
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$apiEndpoint/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(data);

        // Save token and user data
        await _saveAuthData(authResponse.token, authResponse.user);

        // Register user session
        unawaited(SessionService.instance.registerUserSession());

        notifyListeners();
        return authResponse;
      } else if (response.statusCode == 400 &&
          response.body.contains('OAuth authentication')) {
        throw Exception('Esta conta usa Login com Google');
      } else {
        throw Exception('Falha no login: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Email/Password Registration
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$apiEndpoint/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(data);

        // Save token and user data
        await _saveAuthData(authResponse.token, authResponse.user);

        // Register user session
        unawaited(SessionService.instance.registerUserSession());

        notifyListeners();
        return authResponse;
      } else {
        throw Exception('Falha no registro: ${response.body}');
      }
    } catch (e) {
      print('Registration failed: $e');
      rethrow;
    }
  }

  /// Get Google OAuth URL for mobile (uses HTTPS endpoint)
  Future<String> getMobileOAuthUrl() async {
    try {
      final response = await http.get(
        Uri.parse('$apiEndpoint/api/auth/oauth/mobile/start'),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['url'] as String;
      } else {
        throw Exception('Falha ao obter URL de autenticação');
      }
    } catch (e) {
      print('Failed to get OAuth URL: $e');
      rethrow;
    }
  }

  /// Exchange OAuth code for token using mobile callback endpoint
  Future<AuthResponse> exchangeMobileOAuthCode(String code) async {
    try {
      // Call the mobile callback endpoint with the code
      final response = await http.get(
        Uri.parse('$apiEndpoint/api/auth/oauth/mobile/callback')
            .replace(queryParameters: {'code': code}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(data);

        // Save token and user data
        await _saveAuthData(authResponse.token, authResponse.user);

        // Register user session
        unawaited(SessionService.instance.registerUserSession());

        notifyListeners();
        return authResponse;
      } else {
        final error = jsonDecode(response.body)['error'];
        throw Exception('Falha na autenticação OAuth: $error');
      }
    } catch (e) {
      print('OAuth exchange failed: $e');
      rethrow;
    }
  }

  /// Save token from mobile OAuth redirect (receives token directly)
  Future<void> saveTokenFromMobileOAuth(String token) async {
    try {
      // Decode JWT to get user info
      final parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('Token JWT inválido');
      }

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> claims = jsonDecode(decoded);

      // Extract user info from JWT claims
      final userInfo = {
        'id': claims['user_id'] ?? claims['sub'],
        'email': claims['email'],
        'name': claims['name'],
      };

      // Save token and user data
      await _saveAuthData(token, userInfo);

      // Register user session
      unawaited(SessionService.instance.registerUserSession());

      notifyListeners();
    } catch (e) {
      print('Failed to save token from mobile OAuth: $e');
      rethrow;
    }
  }

  /// Get Google OAuth URL (legacy, for web)
  Future<String> getGoogleAuthUrl({String? redirectUri}) async {
    try {
      final uri = redirectUri != null
          ? Uri.parse('$apiEndpoint/api/auth/oauth/url')
              .replace(queryParameters: {'redirect_uri': redirectUri})
          : Uri.parse('$apiEndpoint/api/auth/oauth/url');

      final response = await http.get(uri
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['url'] as String;
      } else {
        throw Exception('Falha ao obter URL de autenticação');
      }
    } catch (e) {
      print('Failed to get OAuth URL: $e');
      rethrow;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      // Call logout endpoint if token exists
      if (_currentToken != null) {
        await http.post(
          Uri.parse('$apiEndpoint/api/auth/logout'),
          headers: {'Authorization': 'Bearer $_currentToken'},
        ).timeout(const Duration(seconds: 30));
      }

      // Clear local data
      await _tokenStorage.clearAll();
      _currentToken = null;
      _currentUser = null;

      notifyListeners();
    } catch (e) {
      print('Logout failed: $e');
      // Clear local data even if API call fails
      await _tokenStorage.clearAll();
      _currentToken = null;
      _currentUser = null;
      notifyListeners();
    }
  }

  /// Check if user is logged in and load stored credentials
  Future<bool> checkLoginStatus() async {
    try {
      final token = await _tokenStorage.getToken();
      final userDataStr = await _tokenStorage.getUserData();

      if (token != null && userDataStr != null) {
        _currentToken = token;
        _currentUser = jsonDecode(userDataStr);

        // Check if token is expired
        if (_isTokenExpired(token)) {
          await logout();
          return false;
        }

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  /// Save authentication data
  Future<void> _saveAuthData(
      String token, Map<String, dynamic> user) async {
    await _tokenStorage.saveToken(token);
    await _tokenStorage.saveUserData(jsonEncode(user));
    _currentToken = token;
    _currentUser = user;
  }

  /// Check if JWT token is expired
  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      // Decode payload (second part)
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> claims = jsonDecode(decoded);

      if (claims['exp'] != null) {
        final expiryDate =
            DateTime.fromMillisecondsSinceEpoch(claims['exp'] * 1000);
        return DateTime.now().isAfter(expiryDate);
      }
    } catch (e) {
      print('Error checking token expiration: $e');
      return true;
    }
    return true;
  }
}
