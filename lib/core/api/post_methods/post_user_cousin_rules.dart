import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:parsa/main.dart';
import 'package:parsa/core/services/auth/backend_auth_service.dart';

import '../fetch_user_transactions.dart';

class PostUserCousinRules {
  static Future<bool> updateCousinRules({
    required int cousinValue,
    required String triggeringId,
    required Map<String, dynamic> changes,
    required bool applyToFuture,
    bool dontAskAgain = false,
  }) async {
    try {
      // Get auth token using Provider
      final backendAuthService = BackendAuthService.instance;
      final token = backendAuthService.token;

      final response = await http.post(
        Uri.parse('$apiEndpoint/api/cousin-rules/'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'cousinId': cousinValue,
          'triggeringId': triggeringId,
          'changes': changes,
          'createRule': applyToFuture,
          'dontAskAgain': dontAskAgain,
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
