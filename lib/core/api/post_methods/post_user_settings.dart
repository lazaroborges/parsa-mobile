import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:parsa/core/api/fetch_user_data_server.dart';
import 'package:parsa/core/database/app_db.dart';
import 'package:parsa/core/services/auth/auth0_class.dart';
import 'package:parsa/main.dart';
import 'package:parsa/core/api/fetch_user_transactions.dart';
import 'package:parsa/core/utils/shared_preferences_async.dart' as app_prefs;

class PostUserSettings {
  static Future<bool> updateAccrualBasisAccountingSetting({
    required bool isAccrualBasisAccounting,
    int maxRetries = 5,
  }) async {
    int retryCount = 0;
    int retryDelayMs = 500; // Start with 500ms delay

    while (true) {
      try {
        // Get auth token using Provider
        final auth0Provider = Auth0Provider.instance;
        final credentials = await auth0Provider.credentials;

        if (credentials == null) {
          throw Exception('User not authenticated');
        }

        final response = await http.post(
          Uri.parse('$apiEndpoint/users/accrual-basis-accounting/'),
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
            'Authorization': 'Bearer ${credentials.accessToken}',
          },
          body: jsonEncode({
            'accrual_basis_accounting': isAccrualBasisAccounting,
          }),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          // Clear existing transactions and fetch fresh data when accounting setting changes
          await _clearAndRefreshTransactions();

          // Fetch and update user data
          await fetchUserDataAtServer();

          return true;
        } else {
          throw Exception(
              'Failed to update user settings: ${response.statusCode}');
        }
      } catch (e) {
        retryCount++;
        print('Error updating user settings (attempt $retryCount): $e');

        // If we've reached max retries, rethrow the exception
        if (retryCount >= maxRetries) {
          print('Max retries reached. Giving up.');
          rethrow;
        }

        // Exponential backoff: 500ms, 1000ms, 2000ms
        await Future.delayed(Duration(milliseconds: retryDelayMs));
        retryDelayMs *= 2; // Double the delay for next retry
        print('Retrying... (delay: ${retryDelayMs}ms)');
      }
    }
  }

  // Helper function to map integer to string for startOfWeek
  static String _mapStartOfWeekToString(int startOfWeek) {
    switch (startOfWeek) {
      case 1: // DateTime.monday:
        return 'monday';
      case 6: // DateTime.saturday:
        return 'saturday';
      case 7: // DateTime.sunday:
        return 'sunday';
      default:
        print('Invalid startOfWeek value: $startOfWeek. Defaulting to monday.');
        return 'monday';
    }
  }

  static Future<bool> updateDatePreferences({
    required int startOfWeek,
    required int startOfMonth,
    int maxRetries = 3,
  }) async {
    int retryCount = 0;
    int retryDelayMs = 300;

    // Use the helper function to convert startOfWeek to string
    String startOfWeekString = _mapStartOfWeekToString(startOfWeek);

    while (retryCount <= maxRetries) {
      try {
        final auth0Provider = Auth0Provider.instance;
        final credentials = await auth0Provider.credentials;

        if (credentials == null) {
          print('User not authenticated, cannot update date preferences.');
          return false;
        }

        final response = await http.post(
          Uri.parse('$apiEndpoint/users/preferences/'),
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
            'Authorization': 'Bearer ${credentials.accessToken}',
          },
          body: jsonEncode({
            'startOfWeek': startOfWeekString,
            'startOfMonth': startOfMonth,
            'useWorkingDay': false,
          }),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          print('Successfully updated date preferences on the server.');
          return true;
        } else if (response.statusCode == 404) {
          // If preferences don't exist on the server, log it
          print(
              'No preferences found on server. The backend should initialize default preferences for users.');
          return true;
        } else {
          print(
              'Failed to update date preferences: ${response.statusCode} ${response.body}');
          // If server returns an error, don't retry
          return false;
        }
      } catch (e) {
        retryCount++;
        print('Error updating date preferences (attempt $retryCount): $e');

        if (retryCount >= maxRetries) {
          print('Max retries reached. Returning false.');
          return false; // Indicate failure after retries
        }

        await Future.delayed(Duration(milliseconds: retryDelayMs));
        retryDelayMs *= 2;
      }
    }

    // Safety exit condition - should never reach here due to the loop conditions
    return false;
  }

  static Future<void> _clearAndRefreshTransactions() async {
    try {
      final db = AppDB.instance;

      // Delete all transactions from the database
      await db.transaction(() async {
        // First delete all transaction-tag associations

        // Then delete all transactions
        await db.delete(db.transactions).go();

        // Mark tables as updated
        db.markTablesUpdated([db.transactions, db.transactionTags]);
      });

      print('Successfully cleared all transactions');

      // Fetch fresh transactions from the server
      await fetchUserTransactions(null);
    } catch (e) {
      print('Error during transaction clearing and refresh: $e');
      // We don't rethrow here to prevent the setting update from failing
      // if the transaction refresh fails
    }
  }

  static Future<Map<String, dynamic>?> fetchUserSettings() async {
    try {
      final auth0Provider = Auth0Provider.instance;
      final credentials = await auth0Provider.credentials;

      if (credentials == null) {
        print('User not authenticated, cannot fetch user settings.');
        return null;
      }

      final response = await http.get(
        Uri.parse('$apiEndpoint/users/preferences/'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer ${credentials.accessToken}',
        },
      );

      if (response.statusCode == 200) {
        print('Successfully fetched user settings from the server.');
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        // If preferences don't exist, simply return null
        print('No preferences found for user.');
        return null;
      } else {
        print(
            'Failed to fetch user settings: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching user settings: $e');
      // Use shared preferences as a fallback in case of network errors
      final prefsAsync = app_prefs.SharedPreferencesAsync.instance;
      return {
        'startOfWeek': await prefsAsync.getStartOfWeek(),
        'startOfMonth': await prefsAsync.getStartOfMonth(),
      };
    }
  }

  static Future<bool> finishOpenFinanceFlow() async {
    try {
      final auth0Provider = Auth0Provider.instance;
      final credentials = await auth0Provider.credentials;

      if (credentials == null) {
        print('User not authenticated, cannot finish open finance flow.');
        return false;
      }

      final response = await http.post(
        Uri.parse('$apiEndpoint/users/finish-openfinance-flow/'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer ${credentials.accessToken}',
        },
      );

      if (response.statusCode == 200) {
        print('Successfully set has_finished_openfinance_flow.');
        return true;
      } else {
        print(
            'Failed to set has_finished_openfinance_flow: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error finishing open finance flow: $e');
      return false;
    }
  }

  static Future<bool> triggerSwipeCardsFlow() async {
    try {
      final auth0Provider = Auth0Provider.instance;
      final credentials = await auth0Provider.credentials;

      if (credentials == null) {
        print('User not authenticated, cannot trigger swipe cards flow.');
        return false;
      }

      final response = await http.post(
        Uri.parse('$apiEndpoint/users/trigger-swipe-cards-flow/'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer ${credentials.accessToken}',
        },
      );

      if (response.statusCode == 200) {
        print('Successfully triggered swipe cards flow.');
        return true;
      } else {
        print(
            'Failed to trigger swipe cards flow: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error triggering swipe cards flow: $e');
      return false;
    }
  }
}
