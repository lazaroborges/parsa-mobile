import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:parsa/core/services/auth/auth0_class.dart';

class PostSubscriptions {
  static Future<bool> sendPurchaseToServerPOST(
    PurchaseDetails purchaseDetails,
    String platform,
    String mobilePurchaseStatus,
    [String? productId] //productId must be optional
  ) async {
    try {
      final auth0Provider = Auth0Provider.instance;
      final credentials = await auth0Provider.credentials;
      
      if (credentials == null) {
        throw Exception('No authentication credentials available');
      }

      //set a string subscriptionID with purchaseDetails.productID, but if this is an empty string, replace with productId
      String subscriptionID = purchaseDetails.productID;
      if (subscriptionID == '') {
        subscriptionID = productId ?? '';
      }


      final Map<String, dynamic> requestBody = {
        'purchase_id': purchaseDetails.purchaseID,
        'subscription_id': subscriptionID,
        'verificationData': purchaseDetails.verificationData.serverVerificationData,
        'device_type': platform,
        'mobilePurchaseStatus': mobilePurchaseStatus,
        'purchase_date': purchaseDetails.transactionDate,
        'notes': purchaseDetails.error?.message ?? '',
      };



      if (purchaseDetails.status == PurchaseStatus.error && purchaseDetails.error != null) {
        requestBody['errorMessage'] = purchaseDetails.error!.message;
        requestBody['errorCode'] = purchaseDetails.error!.code;
        requestBody['details'] = purchaseDetails.error!.details ?? '';
        requestBody['source'] = purchaseDetails.error!.source ?? '';
      }

      final response = await http.post(
        Uri.parse('https://naturally-creative-boxer.ngrok-free.app/subscriptions/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${credentials.accessToken}',
        },
        body: json.encode(requestBody),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error Pushing the purchase to the server: $e');
      // In case of failure, you might want to send 'failed' status
      return false;
    }
  }
}