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
      await FlutterBranchSdk.init(
        enableLogging: kDebugMode,
        disableTracking: false,
      );

      _isInitialized = true;
    } catch (e, stackTrace) {
      // Error handling without debug prints
    }
  }

  /// Cleanup method to be called when the app is terminated or Branch is no longer needed
  static Future<void> dispose() async {
    try {
      _isInitialized = false;
    } catch (e) {
      // Error handling without debug prints
    }
  }
}
