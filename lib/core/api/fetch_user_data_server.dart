import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:parsa/core/services/auth/backend_auth_service.dart';
import 'package:parsa/main.dart'; // Add this import
import 'package:parsa/core/providers/user_data_provider.dart';


// Function that calls the API to fetch the user data like name, avatar photo, and different summarized balances to be displayed at the Dashboard Page Top. Set's a provider for it.


Future<Map<String, dynamic>> fetchUserDataAtServer() async {
  final authService = BackendAuthService.instance;

  final token = authService.token;

  if (token == null) {
    throw Exception('No authentication token found');
  }

  final response = await http.get(
    Uri.parse('$apiEndpoint/api/users/me'),
    headers: {
      'Authorization': 'Bearer $token',
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

// New function to check if the questionnaire is filled
Future<bool> checkQuestionnaireStatus() async {
  try {
    final userData = await fetchUserDataAtServer();
    // Check if filled_questionary exists and is true
    return userData['filled_questionary'] == true;
  } catch (e) {
    print('Error checking questionnaire status: $e');
    // Default to false if there's an error
    return false;
  }
}
