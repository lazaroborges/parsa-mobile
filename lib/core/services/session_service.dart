import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:parsa/core/services/auth/auth0_class.dart';
import 'package:parsa/main.dart' as main;

class SessionService {
  static final SessionService instance = SessionService._internal();
  SessionService._internal();

  bool _hasRegisteredSession = false;

  Future<void> registerUserSession() async {
    // Only register once per app launch
    if (_hasRegisteredSession) return;

    try {
      final response = await http.post(
        Uri.parse('${main.apiEndpoint}/api/sessions/'),
        headers: {
          'Authorization':
              'Bearer ${Auth0Provider.instance.credentials?.accessToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'session_start': "Hello server",
        }),
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
