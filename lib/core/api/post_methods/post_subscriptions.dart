import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:parsa/core/services/auth/auth0_class.dart';
import 'package:parsa/main.dart';

class PostSubscriptions {
  static Future<String> sendPurchaseToServerPOST(
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

      //if device type is == android  and subscriptionID is == premium_monthly1, then set subscriptionID to premium_monthly1_android
      if (subscriptionID == 'premium_monthly1') {
        subscriptionID = 'premium_monthly';
      }


      final Map<String, dynamic> requestBody = {
        'purchase_id': purchaseDetails.purchaseID ?? '',
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
        Uri.parse('$apiEndpoint/subscriptions/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${credentials.accessToken}',
        },
        body: json.encode(requestBody),
      );

      // set the response body to a map
      final responseBody = json.decode(response.body);
      // Check if message exists in responseBody, otherwise return the error message or default
      return responseBody['message'] ?? 'No message received from server';
    } catch (e) {
      print('Error Pushing the purchase to the server: $e');
      // In case of failure, you might want to send 'failed' status
      return 'server_error';
    }
  }
}