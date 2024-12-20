import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:parsa/core/services/auth/auth0_class.dart';
import 'package:parsa/main.dart';


class CheckSubscriptionStatus {
  static Future<bool> verifyRestoredSubscription(
      String productID,
      String purchaseID,
  ) async {

    try {
      final auth0Provider = Auth0Provider.instance;
      final credentials = await auth0Provider.credentials;
      
      if (credentials == null) {
        throw Exception('No authentication credentials available');
      }

      final response = await http.post(
        Uri.parse('$apiEndpoint/subscriptions/apple-sub-status/'),
        headers: {
          'Authorization': 'Bearer ${credentials.accessToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'product_id': productID,
          'purchase_id': purchaseID,
        }),
      );

      if (response.statusCode == 200) {
        //extract the json from the response body
        print('2000000 Response body: ${response.body}');
        return true;
      }
      else if (response.statusCode == 401) {
        print('4010000 Response body: ${response.body}');
        return false;
      }
      else {
        print('4040000 Response body: ${response.body}');
        return false;
      }



    } catch (e) {
      print('Error verifying restored subscription: $e');
      return false;
    }
  }
}