import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:parsa/core/services/auth/auth0_class.dart';
import 'package:flutter/widgets.dart';

Future<Map<String, dynamic>> fetchUserTransactions(BuildContext context) async {
  final auth0 = Auth0Provider.of(context)!.auth0;

  final credentials = await auth0.credentialsManager.credentials();

  final response = await http.get(
    Uri.parse(
        'https://naturally-creative-boxer.ngrok-free.app/api/transactions/'),
    headers: {
      'Authorization': 'Bearer ${credentials.accessToken}',
      'Content-Type': 'application/json',
    },
  );
  print(json.decode(response.body));
  //send the response to syncTransactions()

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load user accounts');
  }
}
