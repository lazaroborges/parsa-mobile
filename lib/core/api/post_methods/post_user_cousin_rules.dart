import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:parsa/core/services/auth/auth0_class.dart';
import 'package:parsa/main.dart';

import '../fetch_user_transactions.dart';

class PostUserCousinRules {
  static Future<bool> updateCousinRules({
    required int cousinValue,
    required String triggeringId,
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
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer ${credentials.accessToken}',
        },
        body: jsonEncode({
          'cousin': cousinValue,
          'triggering_id': triggeringId,
          'changes': changes,
          'create_rule': applyToFuture,
        }, toEncodable: (object) {
          if (object is String) {
            return utf8.decode(utf8.encode(object));
          }
          return object;
        }),
      );

      if (response.statusCode == 200) {
        unawaited(fetchUserTransactions(null, cousinValue: cousinValue));
        return true;
      } else {
        throw Exception(
            'Failed to update cousin rules: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating cousin rules: $e');
      rethrow;
    }
  }
}
