import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:parsa/app/settings/subscriptions/check_subscription_status.dart';
import 'package:parsa/app/settings/subscriptions/success_page.dart';
import 'package:parsa/i18n/translations.g.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:parsa/core/api/post_methods/post_subscriptions.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'dart:io' show Platform;
import 'package:parsa/app/layout/tabs.dart';
import 'package:parsa/app/onboarding/intake.dart';

class PremiumWidget extends StatefulWidget {
  final int? priceMonthly;
  final int? priceYearly;

  const PremiumWidget({Key? key, this.priceMonthly, this.priceYearly}) : super(key: key);

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
  
  // Server prices (from API)
  int? priceMonthly;
  int? priceYearly;

  // Subscription status variables
  String? activeSubscriptionProductId;
  bool hasMonthlySubscription = false;
  bool hasYearlySubscription = false;

  // Add a new flag to track restoration
  bool _isRestoringPurchases = false;

  bool _alreadySaidRestored = false;

  // **New: Track processed purchases**
  final Set<String> _processedPurchases = <String>{};

  @override
  void initState() {
    super.initState();
    
    // Initialize prices from widget parameters
    priceMonthly = widget.priceMonthly ?? 2499; // Default value if null
    priceYearly = widget.priceYearly ?? 24999; // Default value if null

    // Set up the purchase stream listener before initializing the store
    _inAppPurchase.purchaseStream.listen(
      _listenToPurchaseUpdated,
      onDone: () {
        print('Purchase stream completed.');
      },
      onError: (error) {
        print('Purchase stream error: $error');
        setState(() {
          _error = 'Purchase stream error: $error';
        });
      },
    );

    // Initialize the store
    _initializeStore();
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

      // Define all product IDs - Make sure these match EXACTLY with Play Console/App Store
      const Set<String> productIds = {
        'premium_monthly1',
        'premium_monthly11',
        'premium_yearly',
      };

      print('Attempting to query products: $productIds');
      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(productIds);

      print('=== STORE RESPONSE ===');
      print('Products found: ${response.productDetails.length}');

      // print('Not found IDs: ${response.notFoundIDs}');
      // print('Error: ${response.error?.message}');

      // if (response.notFoundIDs.isNotEmpty) {
      //   print('WARNING: Some products were not found: ${response.notFoundIDs}');
      // }

      //print the producsts raw prices
      for (var product in response.productDetails) {
        print('Product: ${product.id} - Price: ${product.price}');
      }
      setState(() {
        _products = response.productDetails;
        _isLoading = false;
      });

      // Check for existing subscriptions
      await _checkSubscriptionStatus();

      // Inside _initializeStore() after querying products
      print('\n=== DETAILED PRODUCT INFO ===');
      for (var product in response.productDetails) {
        print('\nProduct ID: ${product.id}');
        print('Title: ${product.title}');
        print('Description: ${product.description}');
        print('Price: ${product.price}');
        print('Raw Price: ${product.rawPrice}');
        // Print all available properties
        print('Full product details: ${product.toString()}');
      }
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
      print('Detailed SKError: ${e.toString()}');
      setState(() {
        _error = 'Error checking subscription status: ${e.toString()}';
      });
    } finally {
      setState(() => _isRestoringPurchases = false);
    }
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    // Track processed product IDs for iOS restoration
    Set<String> processedProductIds = {};

    for (var purchaseDetails in purchaseDetailsList) {
      final purchaseId = purchaseDetails.purchaseID ?? '';
      final productId = purchaseDetails.productID;

      // Skip if already processed this specific purchase
      if (_processedPurchases.contains(purchaseId)) {
        continue;
      }

      _processedPurchases.add(purchaseId);

      // For iOS restoration, check if we already processed this product type
      if (Theme.of(context).platform == TargetPlatform.iOS &&
          purchaseDetails.status == PurchaseStatus.restored) {
        // Skip if we already processed this product type
        if (processedProductIds.contains(productId)) {
          continue;
        }

        // Skip if we already have an active subscription for this type
        if ((productId == 'premium_monthly1' && hasMonthlySubscription) ||
            (productId == 'premium_yearly' && hasYearlySubscription)) {
          continue;
        }

        // Verify subscription status with backend
        CheckSubscriptionStatus.verifyRestoredSubscription(
          productId,
          purchaseId,
        ).then((isValid) {
          if (isValid) {
            // If the subscription is valid, update the subscription status
            _updateSubscriptionStatus(productId);
          } else {
            print("ELSE CASE: $isValid, ${purchaseDetails.productID}");
            // If the subscription is not valid, treat it as failed
            // setState(() {
            //   _error = 'Compra desconhecida.';
            // });
          }
        });
      }

      // print('Processing purchase status: ${purchaseDetails.status} for ${purchaseDetails.productID}');

      // if (purchaseDetails.status == PurchaseStatus.error) {
      //   _handleErrorPurchase(purchaseDetails);
      // }

      switch (purchaseDetails.status) {
        case PurchaseStatus.purchased:
          _verifyAndDeliverPurchase(purchaseDetails, 'successful');
          break;
        case PurchaseStatus.pending:
          _handlePendingPurchase(purchaseDetails);
          break;
        case PurchaseStatus.restored:
          _verifyAndDeliverPurchase(purchaseDetails, 'restored');
          break;
        case PurchaseStatus.error:
          _handleErrorPurchase(purchaseDetails);
          break;
        default:
          _handleUnknownPurchase(purchaseDetails);
          break;
      }

      if (purchaseDetails.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  void _updateSubscriptionStatus(String? productId) {
    setState(() {
      if (productId == 'premium_monthly1') {
        hasMonthlySubscription = true;
        selectedPlan = 'premium_monthly1';
      } else if (productId == 'premium_yearly') {
        hasYearlySubscription = true;
        selectedPlan = 'premium_yearly';
      }
    });
  }

  Future<void> _verifyAndDeliverPurchase(
      PurchaseDetails purchaseDetails, String status) async {
    if ((purchaseDetails.productID == 'premium_monthly1' &&
            hasMonthlySubscription) ||
        (purchaseDetails.productID == 'premium_yearly' &&
            hasYearlySubscription)) {
      return;
    }

    // print('Starting purchase verification...');
    // print('------Purchase STATUS: ${purchaseDetails.productID} ${purchaseDetails.status}');

    // Update subscription status immediately if successful
    if (status == 'successful') {
      _updateSubscriptionStatus(purchaseDetails.productID);

      // Show success message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Assinatura realizada com sucesso!')),
      );

      // Navigate to success page ONLY for new purchases
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const SubscriptionSuccessPage(),
        ),
      );
    } else if (status == 'restored') {
      _updateSubscriptionStatus(purchaseDetails.productID);
      // Just show a snackbar for restored purchases
      if (!_alreadySaidRestored) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Assinatura restaurada com sucesso!')),
        );
        _alreadySaidRestored = true;
      }
    }

    String purchasePost_code = 'server_error';
    // Call the server with the appropriate status
    try {
      String mobilePurchaseStatus = status;

      purchasePost_code = await PostSubscriptions.sendPurchaseToServerPOST(
        purchaseDetails,
        Theme.of(context).platform == TargetPlatform.iOS ? 'ios' : 'android',
        mobilePurchaseStatus,
        '_verifyAndDeliverPurchase',
      );

      print(
          '------------------- purchasePost_code: $purchasePost_code ${purchaseDetails.status}');
    } catch (e) {
      print('Failed to sync purchase with server: $e');
    }

    if (purchasePost_code == 'created') {
      //print a snackbar with the purchasePost_code
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            duration: Duration(seconds: 3),
            content: Text('Assinatura confirmada com sucesso!')),
      );
    } else if (purchasePost_code == 'confirmed' && !_alreadySaidRestored) {
      //print a snackbar with the purchasePost_code
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            duration: Duration(seconds: 3),
            content: Text('Assinatura resgatada com sucesso!')),
      );
      _alreadySaidRestored = true;
    } else if (purchasePost_code == 'forbidden' && !_alreadySaidRestored) {
      //print a snackbar with the purchasePost_code
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            duration: Duration(seconds: 5),
            content: Text(
                'Assinatura não confirmada. Pode ser que esta conta App Store tenha sido usado primeiro com outro usuário Parsa e não pode ser reutilizada com outra conta Parsa. Em casos de dúvidas, entre em contato com o suporte no menu de Informações.')),
      );
      _alreadySaidRestored = true;
    } else {
      if (!_alreadySaidRestored) {
        //print a snackbar with the purchasePost_code
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              duration: Duration(seconds: 5),
              content: Text(
                  'Operação não autorizada. Em casos de dúvidas, entre em contato com o suporte no menu de Informações.')),
        );
        _alreadySaidRestored = true;
      } else {
        print('alreadySaidRestored: $_alreadySaidRestored');
      }
    }
  }

  Future<void> _handlePendingPurchase(PurchaseDetails purchaseDetails) async {
    print('----------Purchase is pending for ${purchaseDetails.purchaseID}');

    // Optionally show a pending UI to the user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Sua compra está sendo processada. Um momento por favor.'),
        duration: Duration(seconds: 5),
      ),
    );

    // Send the pending status to the server
    try {
      await PostSubscriptions.sendPurchaseToServerPOST(
        purchaseDetails,
        Theme.of(context).platform == TargetPlatform.iOS ? 'ios' : 'android',
        'pending',
        '_handlePendingPurchase',
      );
    } catch (e) {
      print('Failed to sync pending purchase with server: $e');
      // Optionally handle the failure
    }
  }

  Future<void> _handleErrorPurchase(PurchaseDetails purchaseDetails) async {
    setState(() {
      _error = purchaseDetails.error?.message ?? 'Purchase Error';
    });

    // Determine if the error is a rejection
    String mobilePurchaseStatus;
    if (purchaseDetails.error?.code == 'some_rejected_code') {
      mobilePurchaseStatus = 'rejected';
    } else {
      mobilePurchaseStatus = 'failed';
    }

    // Send the error status to the server
    try {
      await PostSubscriptions.sendPurchaseToServerPOST(
          purchaseDetails,
          Theme.of(context).platform == TargetPlatform.iOS ? 'ios' : 'android',
          mobilePurchaseStatus,
          selectedPlan,
          "_handleErrorPurchase");
    } catch (e) {
      print('Failed to sync error purchase with server: $e');
      // Optionally handle the failure
    }
  }

  Future<void> _handleUnknownPurchase(PurchaseDetails purchaseDetails) async {
    print('Unknown purchase status for ${purchaseDetails.productID}');

    // Treat it as failed
    setState(() {
      _error = 'Compra desconhecida.';
    });

    // Send the failed status to the server
    try {
      await PostSubscriptions.sendPurchaseToServerPOST(
          purchaseDetails,
          Theme.of(context).platform == TargetPlatform.iOS ? 'ios' : 'android',
          'failed',
          '_handleUnknownPurchase');
    } catch (e) {
      print('Failed to sync unknown purchase with server: $e');
      // Optionally handle the failure
    }
  }

  Future<void> _buySubscription(ProductDetails product) async {
    try {
      developer.log('Initiating purchase for product: ${product.id}');

      // Clear pending transactions for iOS only
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        developer.log('iOS platform detected - clearing pending transactions');
        final transactions = await SKPaymentQueueWrapper().transactions();
        for (var transaction in transactions) {
          developer.log(
              'Clearing pending transaction: ${transaction.transactionIdentifier}');
          developer.log('Transaction state: ${transaction.transactionState}');
          await SKPaymentQueueWrapper().finishTransaction(transaction);
        }
      }

      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
      );

      // For subscriptions, use buyNonConsumable or buySubscription as appropriate
      final bool success = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      developer.log('Purchase initiation result: $success');

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Não foi possível iniciar a compra. Tente novamente.')),
        );
      }
    } catch (e, stackTrace) {
      developer.log('Purchase error', error: e, stackTrace: stackTrace);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Falha ao processar a compra. Tente novamente.')),
      );
    }
  }

  String _formatPrice(ProductDetails product) {
    // Remove currency symbol and trim whitespace
    String price = product.price.replaceAll(RegExp(r'[^\d.,]'), '').trim();
    return 'R\$$price/mês';
  }

  String _formatYearlyPrice(ProductDetails product) {
    // Remove currency symbol and trim whitespace
    String price = product.price.replaceAll(RegExp(r'[^\d.,]'), '').trim();
    double monthlyPrice = double.parse(price.replaceAll(',', '.')) / 12;
    // Convert back to string with comma as decimal separator
    return 'R\$${monthlyPrice.toStringAsFixed(2).replaceAll('.', ',')}/mês';
  }

  // Format price from server value (e.g. 2499 -> "R$24,99/mês")
  String _formatServerMonthlyPrice() {
    if (priceMonthly == null) return '-';
    
    // Convert from cents to reais with comma as decimal separator
    final double price = priceMonthly! / 100;
    return 'R\$${price.toStringAsFixed(2).replaceAll('.', ',')}/mês';
  }

  // Format yearly price from server value (e.g. 24999 -> "R$20,83/mês")
  String _formatServerYearlyPrice() {
    if (priceYearly == null) return '-';
    
    // Calculate monthly equivalent (yearly price / 12)
    final double monthlyPrice = (priceYearly! / 100) / 12;
    return 'R\$${monthlyPrice.toStringAsFixed(2).replaceAll('.', ',')}/mês';
  }
  
  // Format full yearly price from server value (e.g. 24999 -> "R$249,99")
  String _formatServerYearlyFullPrice() {
    if (priceYearly == null) return '*Cobrança anual única';
    
    // Convert from cents to reais with comma as decimal separator
    final double price = priceYearly! / 100;
    return '*Cobrança anual única de R\$${price.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  Future<void> _openSubscriptionManagement() async {
    final String url;
    if (Platform.isIOS) {
      url = 'https://apps.apple.com/account/subscriptions';
    } else {
      url =
          'https://play.google.com/store/account/subscriptions?package=com.parsa.app';
    }

    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Não foi possível abrir a página de gerenciamento de assinaturas')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    // Determine if the purchase button should be enabled
    bool isPurchaseButtonEnabled = selectedPlan != null &&
        !((selectedPlan == 'premium_monthly1' && hasMonthlySubscription) ||
            (selectedPlan == 'premium_yearly' && hasYearlySubscription));

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
                                image: AssetImage(
                                    'assets/resources/container_background.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                    height: MediaQuery.of(context).padding.top +
                                        8), // Add status bar height + extra padding
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.arrow_back,
                                          color: Color.fromARGB(
                                              255, 255, 255, 255)),
                                      onPressed: () {
                                        // Navigate to TabsPage instead of just popping
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                TabsPage(key: tabsPageKey),
                                          ),
                                        );
                                      },
                                    ),
                                    const Spacer(), // This pushes the header to center
                                    Image.asset(
                                      'assets/resources/header.png',
                                      height: 40,
                                    ),
                                    const Spacer(), // This maintains the center position
                                    const SizedBox(
                                        width:
                                            48), // Same width as IconButton for balance
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Center(
                                  child: Image.asset(
                                    'assets/resources/app_image.png',
                                    height: screenHeight * 0.3 > 280
                                        ? 280
                                        : screenHeight * 0.3,
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
                                          : () => setState(() => selectedPlan =
                                              'premium_monthly1'),
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(16),
                                        decoration: ShapeDecoration(
                                          color: hasMonthlySubscription
                                              ? Colors.grey.shade300
                                              : (selectedPlan ==
                                                      'premium_monthly1'
                                                  ? Colors.blue.shade50
                                                  : Colors.white),
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                              width: 1,
                                              color: hasMonthlySubscription
                                                  ? Colors.grey
                                                  : (selectedPlan ==
                                                          'premium_monthly1'
                                                      ? Colors.blue.shade200
                                                      : Color(0xFFE4E7EC)),
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              hasMonthlySubscription
                                                  ? 'Plano Mensal (Ativo)'
                                                  : 'Plano Mensal',
                                              style: TextStyle(
                                                color: hasMonthlySubscription
                                                    ? Colors.grey
                                                    : (selectedPlan ==
                                                            'premium_monthly1'
                                                        ? Colors.blue.shade700
                                                        : Color(0xFF344053)),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              _formatServerMonthlyPrice(),
                                              style: TextStyle(
                                                color: hasMonthlySubscription
                                                    ? Colors.grey
                                                    : (selectedPlan ==
                                                            'premium_monthly1'
                                                        ? Colors.blue.shade600
                                                        : Color(0xFF667084)),
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
                                          : () => setState(() =>
                                              selectedPlan = 'premium_yearly'),
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(16),
                                        decoration: ShapeDecoration(
                                          color: hasYearlySubscription
                                              ? Colors.grey.shade300
                                              : (selectedPlan ==
                                                      'premium_yearly'
                                                  ? Colors.blue.shade50
                                                  : Colors.white),
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                              width: 1,
                                              color: hasYearlySubscription
                                                  ? Colors.grey
                                                  : (selectedPlan ==
                                                          'premium_yearly'
                                                      ? Colors.blue.shade200
                                                      : Color(0xFFE4E7EC)),
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  hasYearlySubscription
                                                      ? 'Plano Anual (Ativo)'
                                                      : 'Plano Anual',
                                                  style: TextStyle(
                                                    color: hasYearlySubscription
                                                        ? Colors.grey
                                                        : (selectedPlan ==
                                                                'premium_yearly'
                                                            ? Colors
                                                                .blue.shade700
                                                            : Color(
                                                                0xFF344053)),
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Text(
                                                  _formatServerYearlyFullPrice(),
                                                  style: TextStyle(
                                                    color: hasYearlySubscription
                                                        ? Colors.grey
                                                        : (selectedPlan ==
                                                                'premium_yearly'
                                                            ? Colors
                                                                .blue.shade600
                                                            : Color(
                                                                0xFF667084)),
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              _formatServerYearlyPrice(),
                                              style: TextStyle(
                                                color: hasYearlySubscription
                                                    ? Colors.grey
                                                    : (selectedPlan ==
                                                            'premium_yearly'
                                                        ? Colors.blue.shade600
                                                        : Color(0xFF667084)),
                                                fontSize: 14,
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
                                            print(
                                                'selectedPlan: $selectedPlan');
                                            try {
                                              final product =
                                                  _products.firstWhere(
                                                (prod) =>
                                                    prod.id == selectedPlan,
                                              );
                                              _buySubscription(product);
                                            } catch (e) {
                                              print('Product not found: $e');
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Plano selecionado não está disponível')),
                                              );
                                            }
                                          }
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue.shade700,
                                      disabledBackgroundColor:
                                          Colors.blue.shade700,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      'Assinar o Parsa',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16), // Adjusted spacing
                                // Available Banks List
                                SizedBox(
                                  width: 338,
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text:
                                              'Lista de Bancos Disponíveis para Integração.',
                                          style: TextStyle(
                                            color: Color(0xFF475466),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () => launchUrl(Uri.parse(
                                                'https://www.parsa-ai.com.br/bancos')),
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Terms and Privacy Policy
                                SizedBox(
                                  width: 338,
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text:
                                              'Ao continuar, estou de acordo com os ',
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
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () => launchUrl(Uri.parse(
                                                'https://www.parsa-ai.com.br/termos-e-condi%C3%A7%C3%B5es-de-servi%C3%A7o')),
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
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () => launchUrl(Uri.parse(
                                                'https://www.parsa-ai.com.br/pol%C3%ADtica-de-privacidade')),
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
                                const SizedBox(height: 16),
                                GestureDetector(
                                  onTap: _openSubscriptionManagement,
                                  child: Text(
                                    'Gerencie sua assinatura',
                                    style: TextStyle(
                                      color: Color(0xFF475466),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
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
