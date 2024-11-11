import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:parsa/core/presentation/app_colors.dart';
import 'package:parsa/i18n/translations.g.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'dart:developer' as developer;
import 'package:parsa/main.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  List<ProductDetails> _products = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeStore();
    _inAppPurchase.purchaseStream.listen((purchaseDetailsList) {
      print('Received purchase stream update.');
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      print('Purchase stream completed.');
    }, onError: (error) {
      print('Purchase stream error: $error');
      setState(() {
        _error = 'Purchase stream error: $error';
      });
    });
  }

  Future<void> _initializeStore() async {
    try {
      print('=== ANDROID IN-APP PURCHASE DEBUG ===');
      print('Checking store availability...');
      final bool available = await _inAppPurchase.isAvailable();
      print('Store available: $available');

      if (!available) {
        setState(() {
          _error = 'Store not available';
          _isLoading = false;
        });
        return;
      }

      // Define all product IDs
      const Set<String> productIds = {
        'premium_monthl',
        'premium_monthly',  
        'com.parsa.app.premium_monthly',  // Monthly subscription
        'premium_yearly',    // Yearly subscription
        'premium_quarterly', // Quarterly subscription
      };
      
      print('Attempting to query products: $productIds');
      final ProductDetailsResponse response = 
          await _inAppPurchase.queryProductDetails(productIds);
      
      print('=== STORE RESPONSE ===');
      print('Products found: ${response.productDetails.length}');
      print('Not found IDs: ${response.notFoundIDs}');
      print('Error: ${response.error?.message}');
      
      if (response.productDetails.isNotEmpty) {
        print('=== PRODUCT DETAILS ===');
        for (var product in response.productDetails) {
          print('ID: ${product.id}');
          print('Title: ${product.title}');
          print('Description: ${product.description}');
          print('Price: ${product.price}');
        }
      }

      setState(() {
        _products = response.productDetails;
        _isLoading = false;
      });
    } catch (e) {
      print('Error initializing store: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    print('Purchase updated: ${purchaseDetailsList.length} purchases');
    
    for (var purchaseDetails in purchaseDetailsList) {
      print('Purchase status: ${purchaseDetails.status} for ${purchaseDetails.productID}');
      
      if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        _verifyAndDeliverPurchase(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        print('Purchase error: ${purchaseDetails.error}');
        setState(() {
          _error = purchaseDetails.error?.message ?? 'Purchase Error';
        });
      }
      if (purchaseDetails.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  Future<void> _verifyAndDeliverPurchase(PurchaseDetails purchaseDetails) async {
    print('Starting purchase verification...');
    print('Purchase ID: ${purchaseDetails.purchaseID}');
    print('Verification Data: ${purchaseDetails.verificationData.serverVerificationData}');
    try {


      // Send purchaseDetails.purchaseID or purchaseDetails.verificationData.serverVerificationData to your backend
      final response = await http.post(
        Uri.parse('https://naturally-creative-boxer.ngrok-free.app/api/subscription/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'purchaseId': purchaseDetails.purchaseID,
          'verificationData': purchaseDetails.verificationData.serverVerificationData,
          'platform': Theme.of(context).platform == TargetPlatform.iOS ? 'ios' : 'android',
          // Include any other necessary information like user ID
        }),
      );

      if (response.statusCode == 200) {
        // Assuming your backend returns success status
        setState(() {
          // Update UI to reflect successful subscription
        });
        // Optionally, show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Subscription successful!')),
        );
      } else {
        setState(() {
          _error = 'Failed to validate purchase';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error verifying purchase: $e';
      });
    }
  }

  Future<void> _buySubscription(ProductDetails product) async {
    try {
      developer.log('Initiating purchase for product: ${product.id}');
      
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
      );
      
      if (product.id.startsWith('premium')) {
        developer.log('Buying non-consumable product');
        await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      } else {
        developer.log('Buying consumable product');
        await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
      }
    } catch (e, stackTrace) {
      developer.log('Purchase error', error: e, stackTrace: stackTrace);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to process purchase: $e')),
      );
    }
  }

  Widget _buildSubscriptionCard(ProductDetails product) {
    final bool isYearly = product.id == 'yearly_sub';
    final appColors = AppColors.of(context);
    final t = Translations.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isYearly ? Icons.calendar_today : Icons.today,
                  color: appColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  product.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (isYearly) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: appColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'SAVE 20%',
                      style: TextStyle(
                        color: appColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(product.description),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                onPressed: () => _showConfirmationDialog(product),
                child: Text(t.more.subscribe.subscribe_for(price: product.price)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showConfirmationDialog(ProductDetails product) async {
    final t = Translations.of(context);
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(t.more.subscribe.confirm_subscription),
          content: Text(t.more.subscribe.confirm_message(price: product.price)),
          actions: [
            TextButton(
              child: Text(t.more.subscribe.cancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(t.more.subscribe.subscribe),
              onPressed: () {
                Navigator.of(context).pop();
                _buySubscription(product);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.more.subscribe.title),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _products.isEmpty
                  ? Center(child: Text(t.more.subscribe.no_plans_available))
                  : ListView(
                      children: [
                        const SizedBox(height: 16),
                        ..._products.map(_buildSubscriptionCard).toList(),
                      ],
                    ),
    );
  }
}