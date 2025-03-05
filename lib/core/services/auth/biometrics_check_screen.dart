// biometrics_check_screen.dart

import 'package:flutter/material.dart';
import 'package:parsa/core/services/auth/biometrics_service.dart';

class BiometricsCheckScreen extends StatefulWidget {
  final VoidCallback? onBiometricsVerified;

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
    _authenticate();
  }

  void _authenticate() {
    _biometricsService.authenticateAndNavigate(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}