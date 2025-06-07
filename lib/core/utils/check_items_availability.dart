import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:parsa/core/services/auth/auth0_class.dart';
import 'package:parsa/i18n/translations.g.dart';
import 'package:parsa/main.dart';
import 'package:provider/provider.dart';

Future<String?> checkItemAvailability(BuildContext context) async {
  final auth0Provider = Provider.of<Auth0Provider>(context, listen: false);
  final credentials = auth0Provider.credentials;
  final t = Translations.of(context);

  final String? accessToken = credentials?.accessToken;

  final http.Response response;
  try {
    response = await http.get(
      Uri.parse('$apiEndpoint/api/check-item-availability/'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
  } catch (e) {
    print('Network error during checkItemAvailability: $e');
    return t.account.connection_errors.default_message;
  }

  print(
      'Response from checkItemAvailability: ${response.statusCode}, Body: ${response.body}');

  final data = json.decode(response.body);

  if (response.statusCode == 200) {
    final bool isAvailable = data['available'] as bool;
    if (isAvailable) {
      return null;
    }
  } else if (response.statusCode == 403) {
    final bool hasInProgress = data['has_in_progress_items'] as bool;
    final String? code = data['code'] as String?;

    if (code == '4' && hasInProgress == true) {
      return t.account.connection_errors.item_connection_in_progress;
    }

// The return variables are meant to be used only to be displyed in the UI, not for conditional check and control flow. 
    switch (code) {
      case '0':
        return t.account.connection_errors.not_subscribed;
      case '4':
        return t.account.connection_errors.limit_reached;
      case '100':
        return t.account.connection_errors.daily_limit_reached;
      default:
        return t.account.connection_errors.default_message;
    }
  }

  return t.account.connection_errors.default_message;
}
