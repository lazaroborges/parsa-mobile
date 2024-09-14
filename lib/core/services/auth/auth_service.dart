import 'package:flutter/material.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:parsa/app/layout/tabs.dart';
import 'package:parsa/main.dart';
import 'dart:convert';

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

  // Fetch user profile data
  static Future<void> fetchUserProfile(Auth0 auth0) async {
    try {
      final credentials = await auth0.credentialsManager.credentials();
      final accessToken = credentials.accessToken;

      print('accessToken: $accessToken');

      final userProfile = await auth0.api.userProfile(accessToken: accessToken);

      // Print user profile in a readable format
      print('User Profile:');
      print('Name: ${userProfile.customClaims}');
      print('Email: ${userProfile.email}');
      // Add other fields as necessary
    } catch (e) {
      print('Error fetching user profile: $e');
      throw Exception(
          'Error fetching user profile. Please check your network connection and authentication status.');
    }
  }

  // Logout function
  static Future<void> logout(BuildContext context, Auth0 auth0) async {
    try {
      print('Logout attempt started');

      // Perform logout
      await auth0.webAuthentication().logout(
            useHTTPS: true, // Set to true if you want to use HTTPS
          );
      print('Logout successful');

      // Clear stored credentials
      await auth0.credentialsManager.clearCredentials();

      // Navigate back to the login page
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Auth0Service(auth0: auth0)),
        (Route<dynamic> route) => false,
      );
      print('User logged out and navigated to Auth0Service');
    } catch (e) {
      print('Logout failed: $e'); // Enhanced error message
      print(
          'Error during logout attempt. Please ensure you are logged in and try again.');
    }
  }
}
