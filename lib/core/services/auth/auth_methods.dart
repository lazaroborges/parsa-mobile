import 'dart:io';
import 'package:flutter/material.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:parsa/core/services/auth/auth0_class.dart';
import 'package:parsa/core/services/auth/auth_service.dart';

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
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => Auth0Service(
                auth0Provider: Auth0Provider.instance)), // Replace with your login page widget
        (Route<dynamic> route) => false,
      );
      print('User logged out and navigated to LoginPage');
    } catch (e) {
      print('Logout failed: $e'); // Enhanced error message
      print(
          'Error during logout attempt. Please ensure you are logged in and try again.');
    }
  }

  // Check if the user is logged in
  static Future<bool> checkLoginStatus(BuildContext context) async {
    try {
      // Check if the device is online
      final isOnline = await _checkInternetConnection();

      if (isOnline) {
        // If online, check if credentials are valid
        final hasValid =
            await auth0(context).credentialsManager.hasValidCredentials();

        if (hasValid) {
          // Retrieve credentials
          final credentials =
              await auth0(context).credentialsManager.credentials();
          final accessToken = credentials.accessToken;

          if (accessToken != null && accessToken.isNotEmpty) {
            // Validate the token
            final isValid = await _validateToken(context, accessToken);
            if (isValid) {
              return true;
            } else {
              // Token invalid, need to re-login
              await logout(context, auth0(context));
              return false;
            }
          } else {
            // No access token found
            return false;
          }
        } else {
          // No valid credentials
          return false;
        }
      } else {
        // Offline: Let the user in if we have stored credentials
        final hasStoredCredentials =
            await auth0(context).credentialsManager.hasValidCredentials();
        return hasStoredCredentials;
      }
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  // Check internet connectivity
  static Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false; // No internet connection
    }
  }

  // Validate the access token
  static Future<bool> _validateToken(
      BuildContext context, String accessToken) async {
    try {
      // Implement your token validation logic here
      // For simplicity, we'll assume the token is valid
      print('Token validation response: Valid');
      return true;
    } catch (e) {
      print('Token validation failed: $e');
      return false;
    }
  }

  // Helper to get Auth0 instance from context
  static Auth0 auth0(BuildContext context) {
    return Auth0Provider.instance.auth0;
  }
}
