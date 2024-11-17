import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:parsa/core/services/auth/auth0_class.dart';

class PostSubscriptions {
  static Future<bool> verifyPurchase(
    PurchaseDetails purchaseDetails,
    String platform,
    String mobilePurchaseStatus,
  ) async {
    try {
      final auth0Provider = Auth0Provider.instance;
      final credentials = await auth0Provider.credentials;
      
      if (credentials == null) {
        throw Exception('No authentication credentials available');
      }

      final response = await http.post(
        Uri.parse('https://naturally-creative-boxer.ngrok-free.app/subscriptions/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${credentials.accessToken}',
        },
        body: json.encode({
          'purchaseId': purchaseDetails.purchaseID,
          'subscription_id': purchaseDetails.productID,
          'verificationData': purchaseDetails.verificationData.serverVerificationData,
          'device_type': platform,
          'mobilePurchaseStatus': mobilePurchaseStatus,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error Pushing the purchase to the server: $e');
      // In case of failure, you might want to send 'failed' status
      return false;
    }
  }
}