import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:parsa/core/services/auth/auth0_class.dart';
import 'package:parsa/main.dart' as main;
import 'package:parsa/core/services/notification/fcm_service.dart';
import 'package:flutter/foundation.dart';

class SessionService {
  static final SessionService instance = SessionService._internal();
  SessionService._internal();

  bool _hasRegisteredSession = false;

  Future<void> registerUserSession() async {
    // Only register once per app launch
    if (_hasRegisteredSession) return;

    try {
      // Prepare request body
      final Map<String, dynamic> requestBody = {
        'session_start': "Hello server",
      };

      // Register FCM token if not already registered
      // This will handle all token registration through the FCM service
      await FCMService.instance.registerToken();

      final response = await http.post(
        Uri.parse('${main.apiEndpoint}/api/sessions/'),
        headers: {
          'Authorization':
              'Bearer ${Auth0Provider.instance.credentials?.accessToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 201) {
        _hasRegisteredSession = true;
        if (kDebugMode) {
          print('Session registered successfully');
        }
      } else {
        print('Register session: ${response.statusCode}');
      }
    } catch (e) {
      print('Error registering session: $e');
    }
  }
}
