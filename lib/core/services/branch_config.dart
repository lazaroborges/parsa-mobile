import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:parsa/core/routes/go_router_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BranchConfig {
  // Global variables to track initialization
  static bool _isInitialized = false;
  static final Map<String, String> _branchParams = {};

  /// Initialize Branch SDK with proper configuration
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('Initializing Branch SDK');

      // Initialize the SDK
      await FlutterBranchSdk.init(
        enableLogging: kDebugMode,
        disableTracking: false,
      );

      // Enable testing mode in debug builds
      if (kDebugMode) {
        FlutterBranchSdk.validateSDKIntegration();
      }

      // Listen for deep link data
      FlutterBranchSdk.listSession().listen((data) {
        _handleDeepLinkData(data);
      });

      // Get initial deep link data if app was opened via link
      final initialData = await FlutterBranchSdk.getFirstReferringParams();
      if (initialData.isNotEmpty) {
        _handleDeepLinkData(initialData);
      }

      _isInitialized = true;
      debugPrint('Branch SDK initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Branch: $e');
    }
  }

  /// Handle deep link data received from Branch
  static void _handleDeepLinkData(Map<dynamic, dynamic> data) {
    // Log the received data for debugging
    debugPrint('Branch deep link data received: $data');

    // Check if this is a Branch link click
    if (data.containsKey('+clicked_branch_link') &&
        data['+clicked_branch_link'] == true) {
      // Extract deep link path and params
      final linkPath = data['+deeplink_path'] as String?;

      // Save any custom data for access by other parts of the app
      if (data.containsKey('custom_data') && data['custom_data'] is Map) {
        final customData = data['custom_data'] as Map;
        for (final entry in customData.entries) {
          _branchParams[entry.key.toString()] = entry.value.toString();
        }
      }

      // Handle navigation based on deep link path
      if (linkPath != null) {
        _navigateBasedOnPath(linkPath);
      }
    }
  }

  /// Navigate to appropriate screen based on deep link path
  static void _navigateBasedOnPath(String path) {
    debugPrint('Navigating based on path: $path');

    switch (path) {
      case 'subscription':
        goRouter.go('/subscription');
        break;
      case 'accounts':
        final accountId = _branchParams['id'];
        if (accountId != null) {
          goRouter.go('/accounts/$accountId');
        } else {
          goRouter.go('/accounts');
        }
        break;
      case 'transactions':
        final transactionId = _branchParams['id'];
        if (transactionId != null) {
          goRouter.go('/transactions/$transactionId');
        } else {
          goRouter.go('/transactions');
        }
        break;
      case 'budgets':
        final budgetId = _branchParams['id'];
        if (budgetId != null) {
          goRouter.go('/budgets/$budgetId');
        } else {
          goRouter.go('/budgets');
        }
        break;
      default:
        goRouter.go('/');
        break;
    }
  }

  /// Create a Branch link to the subscription page
  static Future<String> createSubscriptionLink({
    String? title,
    String? description,
  }) async {
    // Create Branch Universal Object (BUO)
    final buo = BranchUniversalObject(
      canonicalIdentifier: 'subscription',
      canonicalUrl: 'https://app.parsa-ai.com.br/subscription',
      title: title ?? 'Parsa Premium Subscription',
      contentDescription: description ?? 'Upgrade to Parsa Premium',
      keywords: ['subscription', 'premium', 'finance', 'parsa'],
      publiclyIndex: true,
      locallyIndex: true,
    );

    // Create Branch Link Properties
    final linkProperties = BranchLinkProperties(
      channel: 'app',
      feature: 'subscription',
      campaign: 'premium_offer',
    );

    // Add control params for Branch routing
    linkProperties.addControlParam('\$deeplink_path', 'subscription');
    linkProperties.addControlParam(
        '\$desktop_url', 'https://app.parsa-ai.com.br/products');
    linkProperties.addControlParam('\$android_url',
        'https://play.google.com/store/apps/details?id=com.parsa.app');
    linkProperties.addControlParam('\$ios_url',
        'https://apps.apple.com/app/id'); // Replace with your App Store ID
    linkProperties.addControlParam(
        '\$fallback_url', 'https://app.parsa-ai.com.br/products');

    try {
      // Generate the short URL
      final response = await FlutterBranchSdk.getShortUrl(
        buo: buo,
        linkProperties: linkProperties,
      );

      if (response.success) {
        debugPrint('Branch link created: ${response.result}');
        return response.result;
      } else {
        throw Exception(
            'Branch link creation failed: ${response.errorMessage}');
      }
    } catch (e) {
      debugPrint('Error creating Branch link: $e');
      throw Exception('Failed to create Branch link: $e');
    }
  }

  /// Create a generic deep link to any section of the app
  static Future<String> createDeepLink({
    required String path,
    Map<String, dynamic>? params,
    String? title,
    String? description,
  }) async {
    // Create Branch Universal Object
    final buo = BranchUniversalObject(
      canonicalIdentifier: path,
      canonicalUrl: 'https://app.parsa-ai.com.br/$path',
      title: title ?? 'Parsa - $path',
      contentDescription: description ?? 'Open this $path on Parsa',
      keywords: [path, 'finance', 'parsa'],
      publiclyIndex: true,
      locallyIndex: true,
    );

    // Create Branch Link Properties
    final linkProperties = BranchLinkProperties(
      channel: 'app',
      feature: 'sharing',
      campaign: 'user_sharing',
    );

    // Add deep link path
    linkProperties.addControlParam('\$deeplink_path', path);

    // Add custom data
    if (params != null && params.isNotEmpty) {
      linkProperties.addControlParam('custom_data', params);
    }

    // Add fallback URLs
    linkProperties.addControlParam(
        '\$desktop_url', 'https://app.parsa-ai.com.br/$path');
    linkProperties.addControlParam('\$android_url',
        'https://play.google.com/store/apps/details?id=com.parsa.app');
    linkProperties.addControlParam('\$ios_url',
        'https://apps.apple.com/app/id'); // Replace with your App Store ID
    linkProperties.addControlParam(
        '\$fallback_url', 'https://app.parsa-ai.com.br/$path');

    try {
      // Generate the short URL
      final response = await FlutterBranchSdk.getShortUrl(
        buo: buo,
        linkProperties: linkProperties,
      );

      if (response.success) {
        debugPrint('Branch link created: ${response.result}');
        return response.result;
      } else {
        throw Exception(
            'Branch link creation failed: ${response.errorMessage}');
      }
    } catch (e) {
      debugPrint('Error creating Branch link: $e');
      throw Exception('Failed to create Branch link: $e');
    }
  }
}
