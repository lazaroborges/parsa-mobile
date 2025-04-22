import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:parsa/core/services/auth/auth0_class.dart';
import 'package:parsa/main.dart' as main;
import 'package:parsa/core/services/notification/fcm_service.dart';

class SessionService {
  static final SessionService instance = SessionService._internal();
  SessionService._internal();

  bool _hasRegisteredSession = false;

  Future<void> registerUserSession() async {
    // Only register once per app launch
    if (_hasRegisteredSession) return;

    try {
      // Get the FCM token if available
      
      // Prepare request body
      final Map<String, dynamic> requestBody = {
        'session_start': "Hello server",
      };
      
final messaging = FirebaseMessaging.instance;
    
    // Get and print the FCM token
    final fcmToken = await messaging.getToken();

    if (fcmToken != null) {
      requestBody['fcm_token'] = fcmToken;
    }

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
      } else {
        print('Register session: ${response.statusCode}');
      }
    } catch (e) {
      print('Error registering session: $e');
    }
  }
}
