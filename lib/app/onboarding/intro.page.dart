// New Login Page - Backend Authentication

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:parsa/app/layout/tabs.dart';
import 'package:parsa/app/onboarding/intake.dart';
import 'package:parsa/app/settings/about.page.dart';
import 'package:parsa/core/api/fetch_user_data_server.dart';
import 'package:parsa/core/providers/user_data_provider.dart';
import 'package:parsa/core/services/auth/backend_auth_service.dart';
import 'package:parsa/core/utils/shared_preferences_async.dart';
import 'package:parsa/i18n/translations.g.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';

import '../../core/presentation/app_colors.dart';

final GlobalKey<TabsPageState> tabsPageKey = GlobalKey<TabsPageState>();

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _contentController;
  late Animation<Offset> _logoSlideAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _contentFadeAnimation;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  bool _isRegistering = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();

    // Logo animation controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 750),
      vsync: this,
    );

    // Content fade controller
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Logo slide animation
    _logoSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -0.35),
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOutCubicEmphasized,
    ));

    // Logo scale animation
    _logoScaleAnimation = Tween<double>(
      begin: 2.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOutCubicEmphasized,
    ));

    // Content fade animation
    _contentFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    ));

    // Start animations sequence
    Future.delayed(const Duration(seconds: 1), () {
      _logoController.forward().then((_) {
        _contentController.forward();
      });
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _contentController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $urlString';
    }
  }

  Future<void> _loginWithPassword() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Por favor, preencha email e senha');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = BackendAuthService.instance;
      await authService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (mounted) {
        await _handlePostLogin();
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _registerWithPassword() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _nameController.text.isEmpty) {
      _showError('Por favor, preencha todos os campos');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = BackendAuthService.instance;
      await authService.register(
        email: _emailController.text,
        password: _passwordController.text,
        name: _nameController.text,
      );

      if (mounted) {
        await _handlePostLogin();
      }
    } catch (e) {
      print('Registration failed: $e');
      if (mounted) {
        _showError(e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final authService = BackendAuthService.instance;

      // Step 1: Get OAuth URL from backend mobile endpoint
      final authUrl = await authService.getMobileOAuthUrl();


      // Step 2: Open native authentication session
      // ASWebAuthenticationSession on iOS, Chrome Custom Tabs on Android
      // Backend will redirect to com.parsa.app://oauth-callback?token=...
      final result = await FlutterWebAuth.authenticate(
        url: authUrl,
        callbackUrlScheme: 'com.parsa.app',
      );


      // Step 3: Extract token from callback URL
      final uri = Uri.parse(result);
      final token = uri.queryParameters['token'];

      if (token == null) {
        throw Exception('Token não recebido');
      }

      print('OAuth token received');

      // Step 4: Save token and user data
      await authService.saveTokenFromMobileOAuth(token);

      if (mounted) {
        await _handlePostLogin();
      }
    } catch (e) {
      if (mounted) {
        _showError('Falha no login com Google: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handlePostLogin() async {
    // Fetch user data from server
    await fetchUserDataAtServer();

    // Get user data from provider
    final userData =
        Provider.of<UserDataProvider>(context, listen: false).userData;

    // Check if filled_questionaire is true
    if (userData != null && userData['filled_questionaire'] == true) {
      print("USER DATA: $userData , ${userData['filled_questionaire']}");
      // If questionnaire is filled, go directly to TabsPage
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TabsPage(key: tabsPageKey)),
      );
    } else {
      print("Questionnaire not filled, redirecting to intake form");
      // Check if intake form is completed
      final isIntakeCompleted =
          await SharedPreferencesAsync.instance.getIntakeCompleted();
      if (isIntakeCompleted) {
        // If intake is completed, go to main app (TabsPage)
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TabsPage(key: tabsPageKey)),
        );
      } else {
        // If intake is not completed, show IntakeForm
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const IntakeForm()),
        );
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);
    final t = Translations.of(context);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(height: constraints.maxHeight * 0.05),
                      // Logo and Title Section grouped together
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // Parsa Text - Positioned first in the stack
                              Padding(
                                padding: const EdgeInsets.only(top: 80),
                                child: FadeTransition(
                                  opacity: _contentFadeAnimation,
                                  child: Text(
                                    'Parsa',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineLarge!
                                        .copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: appColors.primary,
                                        ),
                                  ),
                                ),
                              ),
                              // Logo on top
                              SlideTransition(
                                position: _logoSlideAnimation,
                                child: ScaleTransition(
                                  scale: _logoScaleAnimation,
                                  child: const DisplayAppIcon(height: 180),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Login Form Section
                      FadeTransition(
                        opacity: _contentFadeAnimation,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_isRegistering) ...[
                              TextField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: 'Nome',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(Icons.person),
                                ),
                                enabled: !_isLoading,
                              ),
                              const SizedBox(height: 12),
                            ],
                            TextField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.email),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              enabled: !_isLoading,
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: 'Senha',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              obscureText: _obscurePassword,
                              enabled: !_isLoading,
                            ),
                            const SizedBox(height: 24),
                            // Login/Register Button
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                                backgroundColor: appColors.brand,
                                foregroundColor: Colors.white,
                                elevation: 4,
                                shadowColor: appColors.brand.withOpacity(0.6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _isLoading
                                  ? null
                                  : (_isRegistering
                                      ? _registerWithPassword
                                      : _loginWithPassword),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      _isRegistering ? 'Criar Conta' : 'Entrar',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 12),
                            // Toggle Login/Register
                            TextButton(
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      setState(() {
                                        _isRegistering = !_isRegistering;
                                      });
                                    },
                              child: Text(
                                _isRegistering
                                    ? 'Já tem uma conta? Faça login'
                                    : 'Não tem conta? Cadastre-se',
                                style: TextStyle(color: appColors.primary),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Divider
                            Row(
                              children: [
                                Expanded(
                                    child: Divider(color: Colors.grey[300])),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Text(
                                    'ou',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ),
                                Expanded(
                                    child: Divider(color: Colors.grey[300])),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Google Sign In
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _isLoading ? null : _loginWithGoogle,
                              icon: const Icon(Icons.g_mobiledata, size: 28),
                              label: const Text('Continuar com Google'),
                            ),
                            const SizedBox(height: 20),
                            // Updated Text Styling
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text:
                                          'Ao continuar, estou de acordo com os ',
                                      style: const TextStyle(
                                        color: Color(0xFF25282B),
                                        fontSize: 14,
                                        fontFamily: 'Nunito',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Termos de Uso e Serviço',
                                      style: const TextStyle(
                                        color: Color(0xFF25282B),
                                        fontSize: 14,
                                        fontFamily: 'Nunito',
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () => _launchURL(
                                            'https://www.parsa-ai.com.br/termos-e-condições-de-serviço'),
                                    ),
                                    TextSpan(
                                      text: ' e a ',
                                      style: const TextStyle(
                                        color: Color(0xFF25282B),
                                        fontSize: 14,
                                        fontFamily: 'Nunito',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Política de Privacidade',
                                      style: const TextStyle(
                                        color: Color(0xFF25282B),
                                        fontSize: 14,
                                        fontFamily: 'Nunito',
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () => _launchURL(
                                            'https://www.parsa-ai.com.br/política-de-privacidade'),
                                    ),
                                    TextSpan(
                                      text: ' do Parsa. Atualizado em 03/12/2025.',
                                      style: const TextStyle(
                                        color: Color(0xFF25282B),
                                        fontSize: 14,
                                        fontFamily: 'Nunito',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
