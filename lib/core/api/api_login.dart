import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:parsa/core/services/auth/auth0_class.dart';
import 'package:flutter/widgets.dart';
import 'package:parsa/main.dart'; // Add this import

Future<Map<String, dynamic>> apiLogin(BuildContext context) async {
  final auth0 = Auth0Provider.of(context)!.auth0;

  final credentials = await auth0.credentialsManager.credentials();

  final response = await http.get(
    Uri.parse('$apiEndpoint/api/user-info/'),
    headers: {
      'Authorization': 'Bearer ${credentials.accessToken}',
      'Content-Type': 'application/json',
    },
  );

  final data = json.decode(response.body);

  if (response.statusCode == 200) {
    return data;
  } else {
    throw Exception('Failed to load user data');
  }
}
