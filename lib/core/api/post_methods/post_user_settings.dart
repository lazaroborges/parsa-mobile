import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:parsa/core/services/auth/auth0_class.dart';
import 'package:parsa/main.dart';

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
          return true;
        } else {
          throw Exception('Failed to update user settings: ${response.statusCode}');
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
} 