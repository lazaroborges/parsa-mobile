import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:parsa/core/services/auth/auth0_class.dart';
import 'package:parsa/main.dart';
import 'package:provider/provider.dart';

/// Service to interact with notification preferences API endpoints
class NotificationPreferencesService {
  // Singleton instance
  static final NotificationPreferencesService _instance =
      NotificationPreferencesService._internal();

  // Factory constructor
  factory NotificationPreferencesService() => _instance;

  // Internal constructor
  NotificationPreferencesService._internal();

  // Static instance getter
  static NotificationPreferencesService get instance => _instance;

  // Cache for preferences to reduce API calls
  Map<String, bool>? _cachedPreferences;

  /// Get notification preferences from the backend
  Future<Map<String, bool>> getPreferences() async {
    // Return cached preferences if available
    if (_cachedPreferences != null) {
      return _cachedPreferences!;
    }

    try {
      // Get access token
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token available');
      }

      // Make API request
      final response = await http.get(
        Uri.parse('$apiEndpoint/messaging/preferences/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Cache the preferences
        _cachedPreferences = {
          'budgets_enabled': data['budgets_enabled'] ?? true,
          'general_enabled': data['general_enabled'] ?? true,
        };

        return _cachedPreferences!;
      } else {
        if (kDebugMode) {
          print(
              'Failed to get notification preferences: ${response.statusCode}');
          print('Response: ${response.body}');
        }

        // Return defaults if API call fails
        return {
          'budgets_enabled': true,
          'general_enabled': true,
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting notification preferences: $e');
      }

      // Return defaults if error occurs
      return {
        'budgets_enabled': true,
        'general_enabled': true,
      };
    }
  }

  /// Update notification preferences on the backend
  Future<bool> updatePreferences({
    bool? budgetsEnabled,
    bool? generalEnabled,
  }) async {
    try {
      // Get access token
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token available');
      }

      // Prepare request body
      final Map<String, dynamic> requestBody = {};

      if (budgetsEnabled != null) {
        requestBody['budgets_enabled'] = budgetsEnabled;
      }

      if (generalEnabled != null) {
        requestBody['general_enabled'] = generalEnabled;
      }

      // Make API request
      final response = await http.post(
        Uri.parse('$apiEndpoint/messaging/preferences/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        // Update cache if request was successful
        if (_cachedPreferences != null) {
          if (budgetsEnabled != null) {
            _cachedPreferences!['budgets_enabled'] = budgetsEnabled;
          }
          if (generalEnabled != null) {
            _cachedPreferences!['general_enabled'] = generalEnabled;
          }
        }

        return true;
      } else {
        if (kDebugMode) {
          print(
              'Failed to update notification preferences: ${response.statusCode}');
          print('Response: ${response.body}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating notification preferences: $e');
      }
      return false;
    }
  }

  /// Clear cached preferences
  void clearCache() {
    _cachedPreferences = null;
  }

  /// Helper method to get the access token
  Future<String?> _getAccessToken() async {
    try {
      final context = navigatorKey.currentContext;
      if (context == null) {
        if (kDebugMode) {
          print('No context available to get access token');
        }
        return null;
      }

      // Use the Provider to get the Auth0Provider
      final auth0Provider = Provider.of<Auth0Provider>(context, listen: false);
      final credentials = auth0Provider.credentials;
      return credentials?.accessToken;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting access token: $e');
      }
      return null;
    }
  }
}
