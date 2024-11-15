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
import 'package:parsa/core/services/auth/auth0_class.dart';

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

  // Subscription status variables
  String? activeSubscriptionProductId;
  bool hasMonthlySubscription = false;
  bool hasYearlySubscription = false;

  // Add a new flag to track restoration
  bool _isRestoringPurchases = false;

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

      // Check for existing subscriptions
      await _checkSubscriptionStatus();
    } catch (e) {
      print('Error initializing store: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _checkSubscriptionStatus() async {
    if (_isRestoringPurchases) return;
    
    try {
      setState(() => _isRestoringPurchases = true);
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      setState(() {
        _error = 'Error checking subscription status: $e';
      });
    } finally {
      setState(() => _isRestoringPurchases = false);
    }
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    print('Purchase updated: ${purchaseDetailsList.length} purchases');
    
    // Create a Set to track processed purchase IDs
    final processedPurchases = <String>{};
    
    for (var purchaseDetails in purchaseDetailsList) {
      // Skip if we've already processed this purchase
      if (processedPurchases.contains(purchaseDetails.purchaseID)) {
        continue;
      }
      processedPurchases.add(purchaseDetails.purchaseID ?? '');
      
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
    // Skip verification if subscription is already active for this product
    if ((purchaseDetails.productID == 'premium_monthly' && hasMonthlySubscription) ||
        (purchaseDetails.productID == 'premium_yearly' && hasYearlySubscription)) {
      return;
    }

    print('Starting purchase verification...');
    print('Purchase ID: ${purchaseDetails.purchaseID}');
    print('Verification Data: ${purchaseDetails.verificationData.serverVerificationData}');
    try {
      // Get credentials using Auth0Provider
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
          'platform': Theme.of(context).platform == TargetPlatform.iOS ? 'ios' : 'android',
        }),
      );

      if (response.statusCode == 200) {
        // Update the subscription status in the state
        setState(() {
          if (purchaseDetails.productID == 'premium_monthly') {
            hasMonthlySubscription = true;
            selectedPlan = null; // Reset selected plan
          } else if (purchaseDetails.productID == 'premium_yearly') {
            hasYearlySubscription = true;
            selectedPlan = null; // Reset selected plan
          }
        });
        // Optionally, show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Assinatura realizada com sucesso!')),
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

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    // Determine if the purchase button should be enabled
    bool isPurchaseButtonEnabled = selectedPlan != null &&
        !((hasMonthlySubscription && selectedPlan == 'premium_monthly') ||
          hasYearlySubscription);

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
                                      onTap: hasMonthlySubscription
                                          ? null
                                          : () => setState(() => selectedPlan = 'premium_monthly'),
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(16),
                                        decoration: ShapeDecoration(
                                          color: hasMonthlySubscription
                                              ? Colors.grey.shade300
                                              : (selectedPlan == 'premium_monthly' ? Color(0xFFF9F5FF) : Colors.white),
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                              width: 1,
                                              color: hasMonthlySubscription
                                                  ? Colors.grey
                                                  : (selectedPlan == 'premium_monthly' ? Color(0xFFD6BBFB) : Color(0xFFE4E7EC)),
                                            ),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              hasMonthlySubscription ? 'Plano Mensal (Ativo)' : 'Plano Mensal',
                                              style: TextStyle(
                                                color: hasMonthlySubscription
                                                    ? Colors.grey
                                                    : (selectedPlan == 'premium_monthly' ? Color(0xFF52379E) : Color(0xFF344053)),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              'R\$24,90/mês',
                                              style: TextStyle(
                                                color: hasMonthlySubscription
                                                    ? Colors.grey
                                                    : (selectedPlan == 'premium_monthly' ? Color(0xFF7E56D8) : Color(0xFF667084)),
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
                                      onTap: hasYearlySubscription
                                          ? null
                                          : () => setState(() => selectedPlan = 'premium_yearly'),
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(16),
                                        decoration: ShapeDecoration(
                                          color: hasYearlySubscription
                                              ? Colors.grey.shade300
                                              : (selectedPlan == 'premium_yearly' ? Color(0xFFF9F5FF) : Colors.white),
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                              width: 1,
                                              color: hasYearlySubscription
                                                  ? Colors.grey
                                                  : (selectedPlan == 'premium_yearly' ? Color(0xFFD6BBFB) : Color(0xFFE4E7EC)),
                                            ),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text.rich(
                                                    TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: hasYearlySubscription ? 'Plano Anual (Ativo) ' : 'Plano Anual ',
                                                          style: TextStyle(
                                                            color: hasYearlySubscription
                                                                ? Colors.grey
                                                                : (selectedPlan == 'premium_yearly' ? Color(0xFF52379E) : Color(0xFF344053)),
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: 'R\$20,82/mês*',
                                                          style: TextStyle(
                                                            color: hasYearlySubscription
                                                                ? Colors.grey
                                                                : (selectedPlan == 'premium_yearly' ? Color(0xFF7E56D8) : Color(0xFF667084)),
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
                                                      color: hasYearlySubscription
                                                          ? Colors.grey
                                                          : (selectedPlan == 'premium_yearly' ? Color(0xFF7E56D8) : Color(0xFF667084)),
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
                                    onPressed: isPurchaseButtonEnabled
                                        ? () {
                                            print('selectedPlan: $selectedPlan');
                                            try {
                                              final product = _products.firstWhere(
                                                (prod) => prod.id == selectedPlan,
                                              );
                                              _buySubscription(product);
                                            } catch (e) {
                                              print('Product not found: $e');
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Plano selecionado não está disponível')),
                                              );
                                            }
                                          }
                                        : null,
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