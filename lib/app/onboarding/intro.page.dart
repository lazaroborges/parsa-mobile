import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:parsa/app/layout/tabs.dart';
import 'package:parsa/app/settings/about_page.dart';
import 'package:parsa/i18n/translations.g.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:parsa/core/services/auth/auth0_class.dart';

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

  @override
  void initState() {
    super.initState();

    // Logo animation controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Content fade controller
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 800),
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

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);
    final t = Translations.of(context);
    final auth0Provider = Provider.of<Auth0Provider>(context);

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
                      // Bottom Buttons Section
                      FadeTransition(
                        opacity: _contentFadeAnimation,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Updated Button Styling
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () async {
                                print('Login attempt started');
                                try {
                                  await auth0Provider.login();
                                  if (context.mounted) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            TabsPage(key: tabsPageKey),
                                      ),
                                    );
                                  }
                                  print('Navigated to TabsPage');
                                } catch (e) {
                                  print('Login failed: $e');
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(t.auth.login_error),
                                        backgroundColor:
                                            Theme.of(context).colorScheme.error,
                                      ),
                                    );
                                  }
                                }
                              },
                              child: const Text(
                                'Fazer Login',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Nunito',
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
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
                                      text: ' do Parsa.',
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
                            const SizedBox(height: 8),
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
