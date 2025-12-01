import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:parsa/core/database/app_db.dart';
import 'package:parsa/core/providers/user_data_provider.dart';
import 'package:parsa/core/services/auth/backend_auth_service.dart';
import 'package:parsa/main.dart';
import 'package:http/http.dart' as http;
import 'package:parsa/app/onboarding/intro.page.dart';

class AuthMethods {
  // Fetch user profile data
  static Future<void> fetchUserProfile() async {
    try {
      final token = await BackendAuthService.instance.token;
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$apiEndpoint/api/users/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        UserDataProvider.instance.setUserData(data);
        return data;
      } else {
        throw Exception('Failed to fetch user profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      throw Exception(
          'Error fetching user profile. Please check your network connection and authentication status.');
    }
  }

  // Logout function
  static Future<void> logout(BuildContext context) async {
    try {
      print('Logout attempt started');

      final authService = BackendAuthService.instance;
      final accessToken = authService.token;

      if (accessToken != null) {
        final response = await http.post(
          Uri.parse('$apiEndpoint/users/api_logout/'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          print('Logout successful');
        } else {
          print(
              'Invalidação do token falhou. Avise ao time de desenvolvimento do Parsa.');
        }
      }

      // Clear database tables
      await AppDB.instance.transaction(() async {
        // Delete all data except user settings and app data
        await AppDB.instance.delete(AppDB.instance.accounts).go();
        await AppDB.instance.delete(AppDB.instance.transactions).go();
        await AppDB.instance.delete(AppDB.instance.tags).go();
        await AppDB.instance.delete(AppDB.instance.budgets).go();
      });

      // Perform logout with backend auth service
      await authService.logout();
      print('Logout successful');

      // Navigate back to the login page
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const IntroPage()),
        (Route<dynamic> route) => false,
      );
      print('User logged out and navigated to LoginPage');
    } catch (e) {
      print('Logout failed: $e'); // Enhanced error message
      print(
          'Error during logout attempt. Please ensure you are logged in and try again.');
    }
  }

  // Check if the user is logged in
  static Future<bool> checkLoginStatus(BuildContext context) async {
    try {
      // Check if the device is online
      final isOnline = await _checkInternetConnection();

      if (isOnline) {
        // If online, check if credentials are valid
        final hasValid =
            await backendAuthService.checkLoginStatus();

        if (hasValid) {
          // Retrieve credentials
          final token =
              await backendAuthService.token;
          if (token != null && token.isNotEmpty) {
            return true;
          } else {
            return false;
          }
        } else {
          // No valid credentials
          return false;
        }
      } else {
        // Offline: Let the user in if we have stored credentials
        final hasStoredCredentials =
            await backendAuthService.checkLoginStatus();
        return hasStoredCredentials;
      }
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  // Check internet connectivity
  static Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false; // No internet connection
    }
  }

  // Validate the access token
  static Future<bool> _validateToken(
      BuildContext context, String accessToken) async {
    try {
      // Implement your token validation logic here
      // For simplicity, we'll assume the token is valid
      print('Token validation response: Valid');
      return true;
    } catch (e) {
      print('Token validation failed: $e');
      return false;
    }
  }

  // Helper to get Auth0 instance from context
  static BackendAuthService get backendAuthService {
    return BackendAuthService.instance;
  }
}
