import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:parsa/core/services/auth/auth0_class.dart';
import 'package:parsa/main.dart';

class PostUserCousinRules {
  static Future<bool> updateCousinRules({
    required int cousinValue,
    required Map<String, dynamic> changes,
    required bool applyToFuture,
  }) async {
    try {
      // Get auth token using Provider
      final auth0Provider = Auth0Provider.instance;
      final credentials = await auth0Provider.credentials;
      
      if (credentials == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.post(
        Uri.parse('$apiEndpoint/api/cousin-rules/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${credentials.accessToken}',
        },
        body: jsonEncode({
          'cousin_value': cousinValue,
          'changes': changes,
          'apply_to_future': applyToFuture,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to update cousin rules: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating cousin rules: $e');
      rethrow;
    }
  }
}
