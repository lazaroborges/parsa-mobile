import 'dart:async';

import 'package:flutter/material.dart';
// Removed: import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:parsa/core/services/session_service.dart';

// Placeholder Credentials class
class Credentials {
  final String accessToken;
  Credentials({required this.accessToken});
}

// Placeholder Auth0 stub
class Auth0 {
  Auth0({required String domain, required String clientId});
  
  WebAuthentication webAuthentication() => WebAuthentication();
  CredentialsManager get credentialsManager => CredentialsManager();
}

class WebAuthentication {
  Future<Credentials> login({String? audience}) async {
    throw UnimplementedError('Auth0 login not implemented - placeholder');
  }
  
  Future<void> logout() async {
    throw UnimplementedError('Auth0 logout not implemented - placeholder');
  }
}

class CredentialsManager {
  Future<void> storeCredentials(Credentials credentials) async {
    // Placeholder - no-op
  }
  
  Future<void> clearCredentials() async {
    // Placeholder - no-op
  }
  
  Future<bool> hasValidCredentials() async {
    return false; // Always return false for placeholder
  }
  
  Future<Credentials> credentials() async {
    throw UnimplementedError('Auth0 credentials not implemented - placeholder');
  }
}

class Auth0Provider extends ChangeNotifier {
  final Auth0 auth0;
  Credentials? _credentials;

  // Singleton pattern
  static Auth0Provider? _instance;
  static Auth0Provider get instance {
    if (_instance == null) {
      throw Exception('Auth0Provider has not been initialized');
    }
    return _instance!;
  }

  Auth0Provider({required this.auth0}) {
    _instance = this; // Initialize the singleton instance
  }

  Credentials? get credentials => _credentials;

  Future<void> login() async {
    try {
      final result = await auth0.webAuthentication().login(
            audience: 'https://api.parsa.com.br/api',
          );
      _credentials = result;
      await auth0.credentialsManager.storeCredentials(result);
      notifyListeners();
      unawaited(SessionService.instance.registerUserSession());
    } catch (e) {
      print('Login failed ---: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await auth0.webAuthentication().logout();
      await auth0.credentialsManager.clearCredentials();
      _credentials = null;
      notifyListeners();
    } catch (e) {
      print('Logout failed: $e');
      rethrow;
    }
  }

  Future<bool> checkLoginStatus() async {
    try {
      final hasValidCredentials = await auth0.credentialsManager.hasValidCredentials();
      if (hasValidCredentials) {
        _credentials = await auth0.credentialsManager.credentials();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }
}
