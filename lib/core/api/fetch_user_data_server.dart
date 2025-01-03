import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:parsa/core/services/auth/auth0_class.dart';
import 'package:parsa/main.dart'; // Add this import
import 'package:parsa/core/providers/user_data_provider.dart';


// Function that calls the API to fetch the user data like name, avatar photo, and different summarized balances to be displayed at the Dashboard Page Top. Set's a provider for it. 


Future<Map<String, dynamic>> fetchUserDataAtServer() async {
  final auth0 = Auth0Provider.instance.auth0;

  final credentials = await auth0.credentialsManager.credentials();

  final response = await http.get(
    Uri.parse('$apiEndpoint/api/user-info/'),
    headers: {
      'Authorization': 'Bearer ${credentials.accessToken}',
      'Content-Type': 'application/json',
    },
  );

  final data = json.decode(response.body);
  print('data: $data');

  if (response.statusCode == 200) {
    UserDataProvider.instance.setUserData(data);
    return data;
  } else {
    throw Exception('Failed to load user data');
  }
}
