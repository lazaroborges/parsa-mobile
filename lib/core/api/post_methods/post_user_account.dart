import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:parsa/core/api/fetch_user_data_server.dart';
import 'package:parsa/core/database/app_db.dart';
import 'package:parsa/main.dart';


class PostUserAccountService {
  static String get _apiEndpoint => '$apiEndpoint/api/account-insert/';

  /// Serializes the [account] and sends it to the API.
  /// Returns [true] if the operation is successful (HTTP 200), otherwise [false].
  static Future<bool> postUserAccount(
      AccountInDB account, String accessToken) async {
    try {
      // Serialize AccountInDB to JSON
      final Map<String, dynamic> accountJson = {
        'accountId': account.id,
        'name': account.name,
        'iniValue': account.iniValue,
        'date': account.date.toIso8601String(),
        'description': account.description,
        'type': account.type.toString().split('.').last,
        'iconId': account.iconId,
        'displayOrder': account.displayOrder,
        'color': account.color,
        'closingDate': account.closingDate?.toIso8601String(),
        'currencyId': account.currencyId,
        'iban': account.iban,
        'swift': account.swift,
        'balance': account.balance,
        'lastUpdateTime': account.lastUpdateTime.toIso8601String(),
        'connectorID': account.connectorID,
        'isOpenFinance': account.isOpenFinance,
      };

      // Send POST request to the API
      final response = await http.post(
        Uri.parse(_apiEndpoint),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(accountJson),
      );


      if (response.statusCode == 200 || response.statusCode == 201) {
        unawaited(fetchUserDataAtServer());  // Fire and forget

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

  static Future<bool> disconnectAccount(
      String accountId, String accessToken) async {
    return await _postAccountAction(accountId, accessToken, 'disconnect');
  }

  static Future<bool> deleteOpenFinanceAccount(
      String accountId, String accessToken) async {
    return await _postAccountAction(accountId, accessToken, 'delete');
  }

  static Future<bool> _postAccountAction(
      String accountId, String accessToken, String action) async {
    final url = Uri.parse(
        '$apiEndpoint/api/account-insert/actions/$action/');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({'accountId': accountId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print(
            'Failed to $action account. Status Code: ${response.statusCode}, Body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error ${action}ing account: $e');
      return false;
    }
  }

  static Future<bool> updateAccountOrder(AccountInDB account, String accessToken) async {
    final url = Uri.parse('$apiEndpoint/api/account-order/');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'accountId': account.id,
          'order': account.displayOrder,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      print('Failed to update account order. Status: ${response.statusCode}, Body: ${response.body}');
      return false;
    } catch (e) {
      print('Error updating account order: $e');
      return false;
    }
  }
}
