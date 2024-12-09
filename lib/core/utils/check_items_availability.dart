import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:parsa/core/services/auth/auth0_class.dart';
import 'package:parsa/i18n/translations.g.dart';
import 'package:parsa/main.dart';
import 'package:provider/provider.dart';

Future<String?> checkItemAvailability(BuildContext context) async {
  final auth0Provider = Provider.of<Auth0Provider>(context, listen: false);
  final credentials = await auth0Provider.credentials;

  final t = Translations.of(context);

  final response = await http.get(
    Uri.parse('$apiEndpoint/api/check-item-availability/'),
    headers: {
      'Authorization': 'Bearer ${credentials?.accessToken}',
      'Content-Type': 'application/json',
    },
  );

  print(response.body);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['available'] == true) {
      return null; // No error message, Pluggy is available
    }
  } else if (response.statusCode == 403) {
    final data = json.decode(response.body);
    switch (data['code']) {
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

  return 'Erro ao verificar disponibilidade. Tente novamente mais tarde.';
}

