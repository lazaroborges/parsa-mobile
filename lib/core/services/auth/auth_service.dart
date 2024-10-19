import 'package:flutter/material.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:parsa/app/layout/tabs.dart';
import 'package:parsa/core/presentation/app_colors.dart';
import 'package:parsa/i18n/translations.g.dart';

final GlobalKey<TabsPageState> tabsPageKey = GlobalKey<TabsPageState>();

class Auth0Service extends StatelessWidget {
  final Auth0 auth0;

  const Auth0Service({super.key, required this.auth0});

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
                    backgroundColor: appColors.primary,
                    foregroundColor: appColors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(t.auth.login_button),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
