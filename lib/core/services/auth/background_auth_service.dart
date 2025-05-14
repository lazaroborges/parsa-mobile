// This service handles authentication when app returns from background
// If app is in background for more than 2 minutes, authentication is required
//
// Features:
// 1. Tracks when app goes to background and returns to foreground
// 2. If app is in background for more than 2 minutes (configurable), requires re-authentication
// 3. First tries biometric authentication, falls back to PIN code via login screen
// 4. Initialize in TabsPage to ensure it works throughout the app

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:parsa/app/onboarding/intro.page.dart';
import 'package:parsa/core/services/auth/auth0_class.dart';
import 'package:parsa/core/services/auth/auth_methods.dart';
import 'package:parsa/core/services/session_service.dart';
import 'package:parsa/core/services/auth/biometrics_check_screen.dart';

class BackgroundAuthService with WidgetsBindingObserver {
  // Singleton instance
  static final BackgroundAuthService _instance =
      BackgroundAuthService._internal();
  static BackgroundAuthService get instance => _instance;

  // --- Suppress next auth flag ---
  /// If true, skip authentication after background ONCE (e.g., after Pluggy callback)
  static bool suppressNextAuth = false;

  // Private constructor for singleton
  BackgroundAuthService._internal();

  // Fields
  DateTime? _backgroundTime;
  BuildContext? _context;
  final _backgroundThreshold = const Duration(minutes: 2);
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isInitialized = false;

  // Initialize with context
  void initialize(BuildContext context) {
    if (_isInitialized) return;

    _context = context;
    WidgetsBinding.instance.addObserver(this);
    _isInitialized = true;
  }

  // Clean up
  void dispose() {
    if (!_isInitialized) return;

    WidgetsBinding.instance.removeObserver(this);
    _isInitialized = false;
    _context = null;
  }

  // Handle app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // App went to background, record the time
      _backgroundTime = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      // App came back to foreground, check how long it was in background
      _checkBackgroundDuration();
    }
  }

  // Check if authentication is needed after background
  Future<void> _checkBackgroundDuration() async {
    if (_backgroundTime == null || _context == null) return;

    final now = DateTime.now();
    final difference = now.difference(_backgroundTime!);

    // --- Suppress auth if flag is set (e.g., after Pluggy callback) ---
    if (BackgroundAuthService.suppressNextAuth) {
      BackgroundAuthService.suppressNextAuth = false;
      debugPrint(
          '[BackgroundAuthService] Suppressing auth after background due to Pluggy callback.');
      _backgroundTime = null;
      return;
    }

    // If app was in background for more than threshold, require authentication
    if (difference >= _backgroundThreshold) {
      // First try biometric authentication
      await _authenticateUser();
    }

    // Reset background time
    _backgroundTime = null;
  }

  // Authenticate the user
  Future<void> _authenticateUser() async {
    if (_context == null) return;

    // Check if biometrics are available
    bool canCheckBiometrics = await _localAuth.canCheckBiometrics;

    if (canCheckBiometrics) {
      // Try biometric authentication
      await _authenticateWithBiometrics();
    } else {
      // Fallback to login screen if biometrics not available
      _showLoginScreen();
    }
  }

  // Authenticate with biometrics
  Future<void> _authenticateWithBiometrics() async {
    if (_context == null) return;

    // Show BiometricsCheckScreen with white background that covers the app content
    Navigator.of(_context!, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: true, // Makes the route opaque (not transparent)
        pageBuilder: (context, _, __) => WillPopScope(
          onWillPop: () async => false, // Prevent back button
          child: BiometricsCheckScreen(
            onBiometricsVerified: () {
              // On successful authentication, pop the BiometricsCheckScreen
              Navigator.of(context).pop();
              // Update session
              unawaited(SessionService.instance.registerUserSession());
            },
          ),
        ),
      ),
    );
  }

  // Show login screen when authentication is required
  void _showLoginScreen() {
    if (_context == null) return;

    // Log user out
    AuthMethods.logout(_context!, Auth0Provider.instance.auth0);

    // Navigate to login screen
    Navigator.of(_context!, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const IntroPage()),
      (route) => false,
    );
  }
}
