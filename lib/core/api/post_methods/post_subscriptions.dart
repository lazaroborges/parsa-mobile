import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:parsa/core/services/auth/auth0_class.dart';

class SubscriptionService {
  static Future<bool> verifyPurchase(
    PurchaseDetails purchaseDetails,
    String platform,
  ) async {
    try {
      final auth0Provider = Auth0Provider.instance;
      final credentials = await auth0Provider.credentials;
      
      if (credentials == null) {
        throw Exception('No authentication credentials available');
      }

      final response = await http.post(
        Uri.parse('https://naturally-creative-boxer.ngrok-free.app/api/subscription/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${credentials.accessToken}',
        },
        body: json.encode({
          'purchaseId': purchaseDetails.purchaseID,
          'verificationData': purchaseDetails.verificationData.serverVerificationData,
          'platform': platform,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error verifying purchase: $e');
      return false;
    }
  }
}