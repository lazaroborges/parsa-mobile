import 'package:flutter/material.dart';
import 'package:auth0_flutter/auth0_flutter.dart';

import 'package:parsa/core/services/auth/auth_service.dart'; // Import Auth0Service

class AuthMethods {
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
      await Navigator.pushAndRemoveUntil(
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
