import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:parsa/core/services/auth/backend_auth_service.dart';
import 'package:parsa/main.dart';
import 'package:parsa/core/services/notification/permission_service.dart';

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

  // Cache for preferences to reduce API calls within the same session
  Map<String, bool>? _cachedPreferences;

  // Flag to track if we've synced preferences this session
  bool _preferencesRefreshedThisSession = false;

  /// Get notification preferences from the backend
  /// forceRefresh: If true, will fetch fresh data from the server even if cached
  Future<Map<String, bool>> getPreferences({bool forceRefresh = false}) async {
    // Skip cache if force refresh requested or we haven't refreshed this session
    if (forceRefresh ||
        !_preferencesRefreshedThisSession ||
        _cachedPreferences == null) {
      try {
        // First check if notification permission is granted
        final hasPermission =
            await PermissionService.instance.hasNotificationPermission();

        // If permission denied but cache exists, preserve cached values
        if (!hasPermission && _cachedPreferences != null) {
          // Mark session as refreshed
          _preferencesRefreshedThisSession = true;
          return _cachedPreferences!;
        }

        // If permission denied and no cache, use default values
        if (!hasPermission) {
          // If no permission and no cache, use disabled values
          final allDisabled = {
            'budgets_enabled': false,
            'general_enabled': false,
            'transactions_enabled': false,
            'account_enabled': false,
          };

          // Update backend silently
          _updateBackendPreferences(allDisabled);

          // Cache the disabled preferences
          _cachedPreferences = allDisabled;
          _preferencesRefreshedThisSession = true;

          return allDisabled;
        }

        // We have permission, proceed with getting preferences from server
        final authService = BackendAuthService.instance;
        final token = authService.token;
        if (token == null) {
          throw Exception('No authentication token found');
        }

        // Make API request
        final response = await http.get(
          Uri.parse('$apiEndpoint/api/notifications/preferences/'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);

          // Extract data from response structure
          final dynamic data = jsonResponse['data'] ?? jsonResponse;

          // Map backend fields to frontend fields
          // The backend uses 'accounts_enabled', but we use 'account_enabled' in the app
          bool accountEnabled = data.containsKey('accounts_enabled')
              ? data['accounts_enabled'] ?? false
              : data['account_enabled'] ?? false;

          // Cache the preferences with the correct key names for frontend
          _cachedPreferences = {
            'budgets_enabled': data['budgets_enabled'] ?? false,
            'general_enabled': data['general_enabled'] ?? false,
            'transactions_enabled': data['transactions_enabled'] ?? false,
            'account_enabled': accountEnabled, // Use our standardized key name
          };

          _preferencesRefreshedThisSession = true;
          return _cachedPreferences!;
        } else {
          if (kDebugMode) {
            print('Failed to get preferences: ${response.statusCode}');
          }

          // If we already have a cache, keep those values in case of error
          if (_cachedPreferences != null) {
            _preferencesRefreshedThisSession = true;
            return _cachedPreferences!;
          }

          // Return disabled preferences if API call fails and no cache
          final allDisabled = {
            'budgets_enabled': false,
            'general_enabled': false,
            'transactions_enabled': false,
            'account_enabled': false,
          };

          _cachedPreferences = allDisabled;
          _preferencesRefreshedThisSession = true;

          return allDisabled;
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error getting preferences: $e');
        }

        // Return cached preferences if they exist, even if there was an error
        if (_cachedPreferences != null) {
          _preferencesRefreshedThisSession = true;
          return _cachedPreferences!;
        }

        // Return disabled preferences if error occurs and no cache
        final allDisabled = {
          'budgets_enabled': false,
          'general_enabled': false,
          'transactions_enabled': false,
          'account_enabled': false,
        };

        _cachedPreferences = allDisabled;
        _preferencesRefreshedThisSession = true;

        return allDisabled;
      }
    } else {
      // Return cached preferences
      return _cachedPreferences!;
    }
  }

  /// Update notification preferences on the backend
  Future<bool> updatePreferences({
    bool? budgetsEnabled,
    bool? generalEnabled,
    bool? transactionsEnabled,
    bool? accountEnabled,
  }) async {
    try {
      // Get current preferences to preserve unchanged values
      final currentPrefs = _cachedPreferences ?? await getPreferences();

      // Check permission ONLY if trying to enable any preference
      bool hasPermission = true;
      bool needsPermissionCheck = false;

      // Check if we're trying to ENABLE any preference (as opposed to disabling)
      if ((budgetsEnabled == true &&
              currentPrefs['budgets_enabled'] == false) ||
          (generalEnabled == true &&
              currentPrefs['general_enabled'] == false) ||
          (transactionsEnabled == true &&
              currentPrefs['transactions_enabled'] == false) ||
          (accountEnabled == true &&
              currentPrefs['account_enabled'] == false)) {
        needsPermissionCheck = true;
      }

      // Only check permission if trying to enable a preference
      if (needsPermissionCheck) {
        hasPermission =
            await PermissionService.instance.hasNotificationPermission();

        // If no permission, we can't enable any preferences
        if (!hasPermission) {
          // If trying to enable preferences without permission, don't allow
          if (budgetsEnabled == true) budgetsEnabled = false;
          if (generalEnabled == true) generalEnabled = false;
          if (transactionsEnabled == true) transactionsEnabled = false;
          if (accountEnabled == true) accountEnabled = false;
        }
      }

      // Prepare request body - IMPORTANT: only include changed fields
      final Map<String, dynamic> requestBody = {};

      // IMPORTANT: Only include fields that are being changed
      if (budgetsEnabled != null) {
        requestBody['budgets_enabled'] = budgetsEnabled;
      }

      if (generalEnabled != null) {
        requestBody['general_enabled'] = generalEnabled;
      }

      if (transactionsEnabled != null) {
        requestBody['transactions_enabled'] = transactionsEnabled;
      }

      // Use accounts_enabled (plural) for backend, but account_enabled (singular) in app
      if (accountEnabled != null) {
        requestBody['accounts_enabled'] = accountEnabled;
      }

      // Update backend
      final success = await _updateBackendPreferences(requestBody);

      if (success) {
        // Update cache if request was successful
        if (_cachedPreferences != null) {
          // Update only the fields that were sent
          if (budgetsEnabled != null) {
            _cachedPreferences!['budgets_enabled'] = budgetsEnabled;
          }
          if (generalEnabled != null) {
            _cachedPreferences!['general_enabled'] = generalEnabled;
          }
          if (transactionsEnabled != null) {
            _cachedPreferences!['transactions_enabled'] = transactionsEnabled;
          }
          if (accountEnabled != null) {
            _cachedPreferences!['account_enabled'] = accountEnabled;
          }
        }
      }

      return success;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating notification preferences: $e');
      }
      return false;
    }
  }

  // Internal method to update preferences on the backend
  Future<bool> _updateBackendPreferences(
      Map<String, dynamic> requestBody) async {
    try {
      final authService = BackendAuthService.instance;
      final token = authService.token;
      if (token == null) {
        if (kDebugMode) {
          print('No authentication token found');
        }
        return false;
      }

      // Make API request
      final response = await http.post(
        Uri.parse('$apiEndpoint/api/notifications/preferences/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating preferences: $e');
      }
      return false;
    }
  }

  /// Clear cached preferences to force a refresh on next get
  void clearCache() {
    _cachedPreferences = null;
    _preferencesRefreshedThisSession = false;
  }

  /// Reset the session flag to force refresh on next app start
  void resetSessionFlag() {
    _preferencesRefreshedThisSession = false;
  }
}
