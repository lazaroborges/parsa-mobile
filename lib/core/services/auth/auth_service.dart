import 'package:flutter/material.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:parsa/app/layout/tabs.dart';
import 'package:parsa/main.dart';

class Auth0LoginPage extends StatelessWidget {
  final Auth0 auth0;

  const Auth0LoginPage({super.key, required this.auth0});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            print('Callback URL: ${auth0}/android/com.example.app/callback');

            print('Login attempt started');
            try {
              final result = await auth0.webAuthentication().login();

              print('Login successful: ${result.accessToken}');
              // Navigate to the main app page
              await Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => TabsPage(key: tabsPageKey)),
              );
              print('Navigated to TabsPage');
            } catch (e) {
              print('Login failed: $e');
            }
          },
          child: Text('Login with Auth0'),
        ),
      ),
    );
  }
}
