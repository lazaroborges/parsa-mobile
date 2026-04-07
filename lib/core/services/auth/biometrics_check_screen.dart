// biometrics_check_screen.dart

import 'package:flutter/material.dart';
import 'package:parsa/core/services/auth/biometrics_service.dart';

class BiometricsCheckScreen extends StatefulWidget {
  final Future<void> Function()? onBiometricsVerified;

  /// Tracks whether biometrics has been verified or is in progress this session.
  /// Reset by BackgroundAuthService when re-auth is needed.
  static bool verifiedThisSession = false;
  static bool _checkInProgress = false;

  static void resetCheckInProgress() {
    _checkInProgress = false;
  }

  const BiometricsCheckScreen({
    Key? key,
    this.onBiometricsVerified,
  }) : super(key: key);

  @override
  _BiometricsCheckScreenState createState() => _BiometricsCheckScreenState();
}

class _BiometricsCheckScreenState extends State<BiometricsCheckScreen> {
  late final BiometricsService _biometricsService;

  @override
  void initState() {
    super.initState();
    _biometricsService = BiometricsService();

    if (BiometricsCheckScreen.verifiedThisSession ||
        BiometricsCheckScreen._checkInProgress) {
      // Already verified or another check is in progress — skip
      if (BiometricsCheckScreen.verifiedThisSession) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (widget.onBiometricsVerified != null) {
            widget.onBiometricsVerified!();
          }
        });
      }
    } else {
      BiometricsCheckScreen._checkInProgress = true;
      _authenticate();
    }
  }

  void _authenticate() {
    _biometricsService.authenticateAndNavigate(context,
        onVerified: widget.onBiometricsVerified);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
