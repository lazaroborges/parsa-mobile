import 'dart:async';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:parsa/core/routes/go_router_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BranchConfig {
  // Global variables to track initialization
  static bool _isInitialized = false;
  static final Map<String, String> _branchParams = {};
  static StreamSubscription<Map>? _sessionSubscription;

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
        await _validateSDKIntegration();
      }

      // Set up session listener
      await _setupSessionListener();

      // Get initial deep link data if app was opened via link
      await _checkInitialReferringData();

      _isInitialized = true;
      debugPrint('Branch SDK initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('Error initializing Branch: $e');
      debugPrint('Stack trace: $stackTrace');
      // You might want to report this to your error tracking service
    }
  }

  /// Validates the SDK integration
  static Future<void> _validateSDKIntegration() async {
    try {
      FlutterBranchSdk.validateSDKIntegration();
      debugPrint('Branch SDK validation completed');
    } catch (e) {
      debugPrint('Branch SDK validation failed: $e');
    }
  }

  /// Sets up the session listener for deep linking
  static Future<void> _setupSessionListener() async {
    try {
      // Cancel existing subscription if any
      await _sessionSubscription?.cancel();

      _sessionSubscription = FlutterBranchSdk.listSession().listen(
        (data) {
          _handleDeepLinkData(data);
        },
        onError: (error) {
          debugPrint('Branch session listener error: $error');
        },
        cancelOnError: false,
      );
    } catch (e) {
      debugPrint('Error setting up Branch session listener: $e');
    }
  }

  /// Checks initial referring data
  static Future<void> _checkInitialReferringData() async {
    try {
      final Map<dynamic, dynamic> initialParams =
          await FlutterBranchSdk.getFirstReferringParams();

      if (initialParams.isNotEmpty) {
        debugPrint('Initial referring data: $initialParams');
        _handleDeepLinkData(initialParams);
      }

      // Also check latest referring params
      final Map<dynamic, dynamic> latestParams =
          await FlutterBranchSdk.getLatestReferringParams();

      if (latestParams.isNotEmpty) {
        debugPrint('Latest referring data: $latestParams');
      }
    } catch (e) {
      debugPrint('Error checking initial referring data: $e');
    }
  }

  /// Handle deep link data received from Branch
  static void _handleDeepLinkData(Map<dynamic, dynamic> data) {
    debugPrint('Branch deep link data received: $data');

    try {
      // Check if this is a Branch link click
      if (data.containsKey('+clicked_branch_link') &&
          data['+clicked_branch_link'] == true) {
        // Extract deep link path and params
        final String? linkPath = data['+deeplink_path'] as String?;
        final bool isFirstSession = data['+is_first_session'] ?? false;

        // Log session information
        debugPrint('Is first session: $isFirstSession');
        debugPrint('Deep link path: $linkPath');

        // Save any custom data for access by other parts of the app
        _extractAndSaveCustomData(data);

        // Handle navigation based on deep link path
        if (linkPath != null) {
          _navigateBasedOnPath(linkPath);
        }
      }
    } catch (e) {
      debugPrint('Error handling deep link data: $e');
    }
  }

  /// Extract and save custom data from deep link
  static void _extractAndSaveCustomData(Map<dynamic, dynamic> data) {
    try {
      if (data.containsKey('custom_data') && data['custom_data'] is Map) {
        final customData = data['custom_data'] as Map;
        _branchParams.clear(); // Clear existing params

        for (final entry in customData.entries) {
          _branchParams[entry.key.toString()] = entry.value.toString();
        }
        debugPrint('Saved custom data: $_branchParams');
      }
    } catch (e) {
      debugPrint('Error extracting custom data: $e');
    }
  }

  /// Navigate to appropriate screen based on deep link path
  static void _navigateBasedOnPath(String path) {
    debugPrint('Navigating based on path: $path');

    try {
      switch (path) {
        case 'subscription':
          goRouter.go('/subscription');
          break;
        case 'accounts':
          final accountId = _branchParams['id'];
          goRouter.go(accountId != null ? '/accounts/$accountId' : '/accounts');
          break;
        case 'transactions':
          final transactionId = _branchParams['id'];
          goRouter.go(transactionId != null
              ? '/transactions/$transactionId'
              : '/transactions');
          break;
        case 'budgets':
          final budgetId = _branchParams['id'];
          goRouter.go(budgetId != null ? '/budgets/$budgetId' : '/budgets');
          break;
        default:
          goRouter.go('/');
          break;
      }
    } catch (e) {
      debugPrint('Error navigating to path: $e');
      goRouter.go('/'); // Fallback to home on error
    }
  }

  /// Cleanup method to be called when the app is terminated
  static Future<void> dispose() async {
    try {
      await _sessionSubscription?.cancel();
      _sessionSubscription = null;
      _branchParams.clear();
      _isInitialized = false;
    } catch (e) {
      debugPrint('Error disposing Branch config: $e');
    }
  }

  /// Create a Branch link to the subscription page
  static Future<String> createSubscriptionLink({
    String? title,
    String? description,
  }) async {
    if (!_isInitialized) {
      throw Exception('Branch SDK not initialized');
    }

    final buo = BranchUniversalObject(
      canonicalIdentifier: 'subscription',
      canonicalUrl: 'https://app.parsa-ai.com.br/subscription',
      title: title ?? 'Parsa Premium Subscription',
      contentDescription: description ?? 'Upgrade to Parsa Premium',
      keywords: ['subscription', 'premium', 'finance', 'parsa'],
      publiclyIndex: true,
      locallyIndex: true,
    );

    final linkProperties = BranchLinkProperties(
      channel: 'app',
      feature: 'subscription',
      campaign: 'premium_offer',
      stage: 'new user',
      tags: ['premium', 'subscription'],
    )
      ..addControlParam('\$deeplink_path', 'subscription')
      ..addControlParam('\$desktop_url', 'https://app.parsa-ai.com.br/products')
      ..addControlParam('\$android_url',
          'https://play.google.com/store/apps/details?id=com.parsa.app')
      ..addControlParam('\$ios_url',
          'https://apps.apple.com/app/id') // Replace with your App Store ID
      ..addControlParam(
          '\$fallback_url', 'https://app.parsa-ai.com.br/products');

    try {
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
    if (!_isInitialized) {
      throw Exception('Branch SDK not initialized');
    }

    final buo = BranchUniversalObject(
      canonicalIdentifier: path,
      canonicalUrl: 'https://app.parsa-ai.com.br/$path',
      title: title ?? 'Parsa - $path',
      contentDescription: description ?? 'Open this $path on Parsa',
      keywords: [path, 'finance', 'parsa'],
      publiclyIndex: true,
      locallyIndex: true,
    );

    final linkProperties = BranchLinkProperties(
      channel: 'app',
      feature: 'sharing',
      campaign: 'user_sharing',
      stage: 'active user',
      tags: ['share', path],
    )
      ..addControlParam('\$deeplink_path', path)
      ..addControlParam('\$desktop_url', 'https://app.parsa-ai.com.br/$path')
      ..addControlParam('\$android_url',
          'https://play.google.com/store/apps/details?id=com.parsa.app')
      ..addControlParam('\$ios_url', 'https://apps.apple.com/app/id')
      ..addControlParam('\$fallback_url', 'https://app.parsa-ai.com.br/$path');

    if (params != null && params.isNotEmpty) {
      linkProperties.addControlParam('custom_data', params);
    }

    try {
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
