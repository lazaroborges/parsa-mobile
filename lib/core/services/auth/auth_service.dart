import 'package:flutter/material.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:parsa/app/layout/tabs.dart';

final GlobalKey<TabsPageState> tabsPageKey = GlobalKey<TabsPageState>();

class Auth0Service extends StatelessWidget {
  final Auth0 auth0;

  const Auth0Service({super.key, required this.auth0});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            print('Login attempt started');
            try {
              final result = await auth0.webAuthentication().login();
              // Store the credentials
              await auth0.credentialsManager.storeCredentials(result);

              // Navigate to the main app page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => TabsPage(key: tabsPageKey)),
              );
              print('Navigated to TabsPage');
            } catch (e) {
              print('Login failed: $e'); // Enhanced error message
              print(
                  'Error during login attempt. Please check your credentials and network connection.');
            }
          },
          child: Text('Login with Auth0'),
        ),
      ),
    );
  }
}
