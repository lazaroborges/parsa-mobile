import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:parsa/core/services/auth/auth0_class.dart';
import 'package:flutter/widgets.dart'; // Add this import

Future<Map<String, dynamic>> fetchUserData(BuildContext context) async {
  final auth0 = Auth0Provider.of(context)!.auth0;

  print('fetching the user data cowabunga');
  final credentials = await auth0.credentialsManager.credentials();

  final response = await http.get(
    Uri.parse('https://naturally-creative-boxer.ngrok-free.app/api/user'),
    headers: {
      'Authorization': 'Bearer ${credentials.accessToken}',
    },
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load user data');
  }
}
