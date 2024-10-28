//BiometricsService.dart

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:parsa/core/services/auth/auth_methods.dart';
import 'package:parsa/core/services/auth/auth0_class.dart';
import 'package:parsa/app/layout/tabs.dart';
import 'package:parsa/i18n/translations.g.dart';

class BiometricsService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<void> authenticateAndNavigate(BuildContext context) async {
    bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
    bool isAuthenticated = false;

    final t = Translations.of(context);

    try {
      isAuthenticated = await _localAuth.authenticate(
        localizedReason: t.auth.login_reason,
        options: const AuthenticationOptions(
          biometricOnly: false, // Allows device passcode as fallback
          stickyAuth: true,
        ),
      );
    } catch (e) {
      print('Authentication error: $e');
    }

    if (isAuthenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TabsPage()),
      );
    } else {
      try {
        await AuthMethods.logout(context, Auth0Provider.instance.auth0);
      } catch (e) {
        print('Error during logout: $e');
      }
    }
  }
}
