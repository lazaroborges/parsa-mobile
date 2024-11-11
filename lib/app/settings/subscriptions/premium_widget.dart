import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:parsa/core/presentation/app_colors.dart';
import 'package:parsa/i18n/translations.g.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'dart:developer' as developer;
import 'package:parsa/main.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

class PremiumWidget extends StatefulWidget {
  @override
  _PremiumWidgetState createState() => _PremiumWidgetState();
}

class _PremiumWidgetState extends State<PremiumWidget> {
  String? selectedPlan;

  // In-App Purchase variables
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
        'premium_monthly',
        'premium_yearly',
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
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _products.isEmpty
                  ? Center(child: Text(t.more.subscribe.no_plans_available))
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          // Top container with background image
                          Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              image: const DecorationImage(
                                image: AssetImage('assets/resources/container_background.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: MediaQuery.of(context).padding.top + 8), // Add status bar height + extra padding
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.arrow_back, color: Color.fromARGB(255, 255, 255, 255)),
                                      onPressed: () => Navigator.of(context).pop(),
                                    ),
                                    const Spacer(), // This pushes the header to center
                                    Image.asset(
                                      'assets/resources/header.png',
                                      height: 40,
                                    ),
                                    const Spacer(), // This maintains the center position
                                    const SizedBox(width: 48), // Same width as IconButton for balance
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Center(
                                  child: Image.asset(
                                    'assets/resources/app_image.png',
                                    height: screenHeight * 0.3 > 280 ? 280 : screenHeight * 0.3,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Rest of the content with original padding
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Column(
                              children: [
                                const SizedBox(height: 24),
                                // Title
                                const Text(
                                  'Parsa Premium - Teste por 7 dias com direito a reembolso total',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF0F1728),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Subtitle
                                const Text(
                                  'Integração via Open Finance com até 3 contas, sincronização automática, insights precisos.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF475466),
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 28),
                                // Plans
                                Column(
                                  children: [
                                    // Monthly Plan
                                    GestureDetector(
                                      onTap: () => setState(() => selectedPlan = 'premium_monthly'),
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(16),
                                        decoration: ShapeDecoration(
                                          color: selectedPlan == 'premium_monthly' ? Color(0xFFF9F5FF) : Colors.white,
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                              width: 1,
                                              color: selectedPlan == 'premium_monthly' ? Color(0xFFD6BBFB) : Color(0xFFE4E7EC),
                                            ),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Plano Mensal',
                                              style: TextStyle(
                                                color: selectedPlan == 'premium_monthly' ? Color(0xFF52379E) : Color(0xFF344053),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              'R\$24,90/mês',
                                              style: TextStyle(
                                                color: selectedPlan == 'premium_monthly' ? Color(0xFF7E56D8) : Color(0xFF667084),
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    // Annual Plan
                                    GestureDetector(
                                      onTap: () => setState(() => selectedPlan = 'premium_yearly'),
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(16),
                                        decoration: ShapeDecoration(
                                          color: selectedPlan == 'premium_yearly' ? Color(0xFFF9F5FF) : Colors.white,
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                              width: 1,
                                              color: selectedPlan == 'premium_yearly' ? Color(0xFFD6BBFB) : Color(0xFFE4E7EC),
                                            ),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text.rich(
                                                    TextSpan(
                                                      text: 'Plano Anual ',
                                                      style: TextStyle(
                                                        color: selectedPlan == 'premium_yearly' ? Color(0xFF52379E) : Color(0xFF344053),
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                      children: [
                                                        TextSpan(
                                                          text: 'R\$20,82/mês*',
                                                          style: TextStyle(
                                                            color: selectedPlan == 'premium_yearly' ? Color(0xFF7E56D8) : Color(0xFF667084),
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w400,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    '*Cobrança anual única de R\$249,90',
                                                    style: TextStyle(
                                                      color: selectedPlan == 'premium_yearly' ? Color(0xFF7E56D8) : Color(0xFF667084),
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 28),
                                // Premium Button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      print('selectedPlan: $selectedPlan');
                                      if (selectedPlan != null) {
                                        try {
                                          final product = _products.firstWhere(
                                            (prod) => prod.id == selectedPlan,
                                          );
                                          _buySubscription(product);
                                        } catch (e) {
                                          print('Product not found: $e');
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Please select a plan')),
                                          );
                                        }
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Please select a plan')),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF7E56D8),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      'Seja Premium',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16), // Adjusted spacing
                                // Terms and Privacy Policy
                                SizedBox(
                                  width: 338,
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Ao continuar, estou de acordo com os ',
                                          style: TextStyle(
                                            color: Color(0xFF475466),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        TextSpan(
                                          text: 'Termos de Uso e Serviço',
                                          style: TextStyle(
                                            color: Color(0xFF475466),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            decoration: TextDecoration.underline,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () => launchUrl(Uri.parse('https://www.parsa-ai.com.br/termos-e-condi%C3%A7%C3%B5es-de-servi%C3%A7o')),
                                        ),
                                        TextSpan(
                                          text: ' e a ',
                                          style: TextStyle(
                                            color: Color(0xFF475466),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        TextSpan(
                                          text: 'Política de Privacidade',
                                          style: TextStyle(
                                            color: Color(0xFF475466),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            decoration: TextDecoration.underline,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () => launchUrl(Uri.parse('https://www.parsa-ai.com.br/pol%C3%ADtica-de-privacidade')),
                                        ),
                                        TextSpan(
                                          text: ' do Parsa.',
                                          style: TextStyle(
                                            color: Color(0xFF475466),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}