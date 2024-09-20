import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:parsa/core/services/auth/auth0_class.dart';
import 'package:flutter/widgets.dart';

Future<Map<String, dynamic>> fetchUserAccounts(BuildContext context) async {
  final auth0 = Auth0Provider.of(context)!.auth0;

  final credentials = await auth0.credentialsManager.credentials();

  final response = await http.get(
    Uri.parse('https://naturally-creative-boxer.ngrok-free.app/api/accounts/'),
    headers: {
      'Authorization': 'Bearer ${credentials.accessToken}',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load user accounts');
  }
}
