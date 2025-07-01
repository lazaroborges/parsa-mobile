import 'dart:async';

import 'package:flutter/material.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:parsa/core/services/session_service.dart';

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
      print('=== DEBUG: Auth0 login starting ===');
      
      final result = await auth0
          .webAuthentication(scheme: 'com.parsa.app')
          .login(audience: 'https://api.parsa.com.br/api');
          
      print('=== DEBUG: Login successful ===');
      _credentials = result;
      await auth0.credentialsManager.storeCredentials(result);
      notifyListeners();
      unawaited(SessionService.instance.registerUserSession());
    } catch (e) {
      print('=== DEBUG: Login failed with error: $e ===');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await auth0.webAuthentication(scheme: 'com.parsa.app').logout();
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
