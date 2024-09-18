import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:parsa/core/services/auth/auth0_class.dart';
import 'package:flutter/widgets.dart'; // Add this import

Future<Map<String, dynamic>> apiLogin(BuildContext context) async {
  final auth0 = Auth0Provider.of(context)!.auth0;

  final credentials = await auth0.credentialsManager.credentials();

  final response = await http.post(
    Uri.parse(
        'https://naturally-creative-boxer.ngrok-free.app/api/auth-mobile/'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'access_token': credentials.accessToken,
    }),
  );

  final data = json.decode(response.body);

  if (response.statusCode == 200) {
    return data;
  } else {
    throw Exception('Failed to load user data');
  }
}
