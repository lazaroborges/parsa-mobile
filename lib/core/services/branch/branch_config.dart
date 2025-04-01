import 'dart:async';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter/foundation.dart';

class BranchConfig {
  // Global variables to track initialization
  static bool _isInitialized = false;

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

      _isInitialized = true;
      debugPrint('Branch SDK initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('Error initializing Branch: $e');
      debugPrint('Stack trace: $stackTrace');
      // Consider reporting this error
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

  /// Cleanup method to be called when the app is terminated or Branch is no longer needed
  static Future<void> dispose() async {
    try {
      _isInitialized =
          false; // Reset initialization status if needed on dispose/re-init
      debugPrint('BranchConfig disposed');
    } catch (e) {
      debugPrint('Error disposing Branch config: $e');
    }
  }
}
