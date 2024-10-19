import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:parsa/app/layout/tabs.dart';
import 'package:parsa/core/presentation/app_colors.dart';
import 'package:parsa/i18n/translations.g.dart';
import 'package:url_launcher/url_launcher.dart';

final GlobalKey<TabsPageState> tabsPageKey = GlobalKey<TabsPageState>();

class Auth0Service extends StatelessWidget {
  final Auth0 auth0;

  const Auth0Service({super.key, required this.auth0});

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
    final theme = Theme.of(context);
    final appColors = AppColors.of(context);
    final t = Translations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/png_icons/1.png',
                        height: 240,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        t.auth.app_name,
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: appColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: Column(
                  children: [
                    Container(
                      width: 343,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () async {
                          print('Login attempt started');
                          try {
                            final result = await auth0.webAuthentication().login(
                                  audience: 'https://api.parsa.com.br/api',
                                );
                            await auth0.credentialsManager.storeCredentials(result);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TabsPage(key: tabsPageKey)),
                            );
                            print('Navigated to TabsPage');
                          } catch (e) {
                            print('Login failed: $e');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(t.auth.login_error),
                                backgroundColor: theme.colorScheme.error,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF485D92),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                          shadowColor: Color(0x0C101828),
                        ),
                        child: Text(
                          t.auth.login_button,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 27),
                    SizedBox(
                      width: 338,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Ao continuar, estou de acordo com os ',
                              style: TextStyle(
                                color: Color(0xFF475466),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            TextSpan(
                              text: 'Termos de Uso e Serviço',
                              style: TextStyle(
                                color: Color(0xFF475466),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => _launchURL('https://www.parsa-ai.com.br/termos-e-condi%C3%A7%C3%B5es-de-servi%C3%A7o'),
                            ),
                            TextSpan(
                              text: ' e a ',
                              style: TextStyle(
                                color: Color(0xFF475466),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            TextSpan(
                              text: 'Política de Privacidade',
                              style: TextStyle(
                                color: Color(0xFF475466),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => _launchURL('https://www.parsa-ai.com.br/pol%C3%ADtica-de-privacidade'),
                            ),
                            TextSpan(
                              text: ' do Parsa.',
                              style: TextStyle(
                                color: Color(0xFF475466),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
