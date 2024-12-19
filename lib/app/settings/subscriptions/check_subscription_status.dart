import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:parsa/core/services/auth/auth0_class.dart';
import 'package:parsa/main.dart';


class CheckSubscriptionStatus {
  static Future<bool> verifyRestoredSubscription(
    PurchaseDetails purchaseDetails,
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
        body: json.encode({
          'purchase_id': purchaseDetails.purchaseID,
          'product_id': purchaseDetails.productID,
          'verification_data': purchaseDetails.verificationData.serverVerificationData,
          'transaction_date': purchaseDetails.transactionDate,
          'platform': 'ios',
          'status': purchaseDetails.status,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['is_active'] ?? false;
      }
      
      print('Verification failed with status: ${response.statusCode}');
      print('Response body: ${response.body}');
      return false;

    } catch (e) {
      print('Error verifying restored subscription: $e');
      return false;
    }
  }
}