import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:parsa/app/settings/subscriptions/success_page.dart';
import 'package:parsa/i18n/translations.g.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:parsa/core/api/post_methods/post_subscriptions.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

class PremiumWidget extends StatefulWidget {
  @override
  _PremiumWidgetState createState() => _PremiumWidgetState();
}

class _PremiumWidgetState extends State<PremiumWidget> {
  String? selectedPlan;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  List<ProductDetails> _products = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeStore();
    
    _inAppPurchase.purchaseStream.listen(
      _listenToPurchaseUpdated,
      onDone: () => print('Done'),
      onError: (error) => setState(() => _error = error.toString()),
    );
  }

  Future<void> _initializeStore() async {
    try {
      final bool available = await _inAppPurchase.isAvailable();
      if (!available) {
        setState(() {
          _error = 'Store not available';
          _isLoading = false;
        });
        return;
      }

      const Set<String> productIds = {
        'premium_monthly',
        'premium_yearly',
      };
      
      final ProductDetailsResponse response = 
          await _inAppPurchase.queryProductDetails(productIds);
      
      setState(() {
        _products = response.productDetails;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        _verifyPurchase(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        _handleError(purchaseDetails.error!);
      }
    }
  }

  Future<void> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    await PostSubscriptions.sendPurchaseToServerPOST(
      purchaseDetails,
      'ios',
      'successful',
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SubscriptionSuccessPage()),
    );
  }

  void _handleError(IAPError error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error.message)),
    );
  }

  Future<void> _clearPendingTransactions() async {
    final transactions = await SKPaymentQueueWrapper().transactions();
    for (var transaction in transactions) {
      print(transaction.transactionIdentifier);
      print(transaction.transactionState);
      await SKPaymentQueueWrapper().finishTransaction(transaction);
    }
  }

  Future<void> _buySubscription(ProductDetails product) async {
    await _clearPendingTransactions();
    
    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: product,
    );
    
    try {
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to make purchase: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(body: Center(child: Text(_error!)));
    }

    return Scaffold(
      appBar: AppBar(title: Text('Premium Subscription')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Choose your plan',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 20),
            ..._products.map((product) => Card(
              child: ListTile(
                title: Text(product.title),
                subtitle: Text(product.description),
                trailing: Text(product.price),
                selected: selectedPlan == product.id,
                onTap: () => setState(() => selectedPlan = product.id),
              ),
            )),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: selectedPlan == null ? null : () {
                final product = _products.firstWhere(
                  (p) => p.id == selectedPlan,
                );
                _buySubscription(product);
              },
              child: Text('Subscribe Now'),
            ),
          ],
        ),
      ),
    );
  }
}
