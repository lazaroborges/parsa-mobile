import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:parsa/core/database/app_db.dart';
import 'package:parsa/core/models/account/account.dart';

class DeleteUserBankAccount {
  static const String _apiEndpoint =
      'https://naturally-creative-boxer.ngrok-free.app/api/delete-bank-account/';

  /// Serializes the [account] and sends it to the API.
  /// Returns [true] if the operation is successful (HTTP 200), otherwise [false].
  static Future<bool> deleteUser(String accountId, String accessToken) async {
    try {
      // Serialize AccountInDB to JSON
      final Map<String, dynamic> accountJson = {
        'accountId': accountId,
      };

      // Send POST request to the API
      final response = await http.delete(
        Uri.parse(_apiEndpoint),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(accountJson),
      );

      print(
          'LA respuesta es la verdad ${response.body} ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print(
            'Failed to post account. Status Code: ${response.statusCode}, Body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error posting account: $e');
      return false;
    }
  }
}
