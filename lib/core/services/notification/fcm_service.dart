import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:parsa/core/services/notification/notification_preferences_service.dart';
import 'package:parsa/core/services/notification/permission_service.dart';
import 'package:parsa/main.dart';
import '../../../firebase_options.dart';
import 'package:http/http.dart' as http;
import 'package:parsa/core/services/auth/auth0_class.dart';
import 'package:provider/provider.dart';
import 'package:parsa/core/routes/navigation_delegate.dart';

enum NotificationCategory {
  budgets,
  general,
  transactions,
  account,
}

// Top-level background message handler: must be a top-level function.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
    print("Message data: ${message.data}");
    if (message.notification != null) {
      print("Message notification title: ${message.notification!.title}");
      print("Message notification body: ${message.notification!.body}");
    }
  }
}

class FCMService {
  // Singleton instance
  static final FCMService _instance = FCMService._internal();

  // Factory constructor to return the singleton instance
  factory FCMService() => _instance;

  // Private constructor for singleton pattern
  FCMService._internal();

  // Getter for the singleton instance
  static FCMService get instance => _instance;

  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  // In-memory map of topic subscription states
  final Map<NotificationCategory, bool> _notificationFilters = {};

  // Flag to track if FCM is initialized
  bool _isInitialized = false;

  // Flag to track if initialization is in progress to prevent concurrent calls
  bool _isInitializing = false;

  // Flag to track if token has been registered with server
  bool _isTokenRegistered = false;

  // Get FCM token using the permission service
  Future<String?> getToken() async {
    return await PermissionService.instance.getToken();
  }

  // Check if notifications are enabled overall
  Future<bool> getNotificationsEnabled() async {
    final prefs =
        await NotificationPreferencesService.instance.getPreferences();
    // Consider notifications enabled if any category is enabled
    return prefs['budgets_enabled'] == true ||
        prefs['general_enabled'] == true ||
        prefs['transactions_enabled'] == true ||
        prefs['account_enabled'] == true;
  }

  // Method to reset initialization state for reinitializing after permission changes
  void resetInitializationState() {
    _isInitialized = false;
    _isInitializing = false;
    _isTokenRegistered = false;
  }

  // Register the FCM token for any service that needs it
  Future<bool> registerToken() async {
    if (!_isInitialized) {
      if (kDebugMode) {
        print('Cannot register token: FCM not initialized');
      }
      return false;
    }

    if (_isTokenRegistered) {
      return true;
    }

    final token = await PermissionService.instance.getToken();
    if (token == null) {
      if (kDebugMode) {
        print('Cannot register token: No token available');
      }
      return false;
    }

    final result = await saveTokenToServer(token);
    _isTokenRegistered = result;
    return result;
  }

  // Centralized method that handles both permission request and FCM initialization
  Future<bool> requestPermissionAndInitialize() async {
    // Request permissions first
    final hasPermission =
        await PermissionService.instance.requestPermissionWithFCM();

    if (!hasPermission) {
      if (kDebugMode) {
        print("Notification permission denied by user");
      }
      return false;
    }

    // If permission granted, initialize FCM
    await initialize();

    // Register token with server
    await registerToken();

    return true;
  }

  Future<void> initialize() async {
    // Prevent multiple initializations
    if (_isInitialized || _isInitializing) return;

    _isInitializing = true;

    try {
      // If Firebase is not yet initialized, initialize it.
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform);
      }

      // Only proceed if OS-level notification permission is already granted
      final hasPermission =
          await PermissionService.instance.hasNotificationPermission();
      if (!hasPermission) {
        if (kDebugMode) {
          print("FCM initialization: notification permission not granted");
        }
        // Mark as initialized but exit early
        _isInitialized = true;
        _isInitializing = false;
        return;
      }

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Listen for messages when the app is in the foreground.
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          print("Received a foreground message: ${message.messageId}");
          print('Message data: ${message.data}');
        }
        // TODO: Handle notification display
        // Store the message data for displaying in the app
        // This would be handled by a notification display service in a real app
      });

      // Listen for when a user taps on a notification (app opened via notification).
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('User tapped on notification: ${message.messageId}');
          print('Message data: ${message.data}');
        }

        if (message.data.containsKey('route')) {
          final route = message.data['route'];
          final queryParams = message.data['queryParams'] != null
              ? jsonDecode(message.data['queryParams']) as Map<String, String>
              : null;

          if (kDebugMode) {
            print('Notification route: $route');
            print('Notification queryParams: $queryParams');
          }

          // Use NavigationDelegate to navigate based on the route
          NavigationDelegate.instance.navigateBasedOnNotificationRoute(route,
              queryParams: queryParams);
        }
      });

      // Get the FCM token and register it with backend
      final token = await PermissionService.instance.getToken();
      if (token != null) {
        final success = await saveTokenToServer(token);
        _isTokenRegistered = success;

        // Setup token refresh listener
        messaging.onTokenRefresh.listen((newToken) async {
          if (kDebugMode) {
            print('FCM Token refreshed: $newToken');
          }
          // Update our registered state
          _isTokenRegistered = await saveTokenToServer(newToken);
        });
      }

      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        if (kDebugMode) {
          print(
              'App was terminated and opened via notification: ${initialMessage.messageId}');
          print('Message data: ${initialMessage.data}');
        }
        // Handle the notification data
        final route = initialMessage.data['route'];
        final queryParams = initialMessage.data['queryParams'] != null
            ? jsonDecode(initialMessage.data['queryParams'])
                as Map<String, String>
            : null;

        if (kDebugMode) {
          print('Terminated app notification route: $route');
          print('Terminated app notification queryParams: $queryParams');
        }

        // Use NavigationDelegate to navigate based on the route
        NavigationDelegate.instance
            .navigateBasedOnNotificationRoute(route, queryParams: queryParams);
      }

      // Load user preferences
      await _loadPreferencesFromBackend();

      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        print("Error initializing FCM: $e");
      }
    } finally {
      _isInitializing = false;
    }
  }

  /// Save the FCM token to your backend server with retry logic
  Future<bool> saveTokenToServer(String? token,
      {int maxRetries = 3, int delayMs = 1000}) async {
    if (token == null) return false;

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        // Get access token from Auth0Provider
        final accessToken = await _getAccessToken();
        if (accessToken == null) {
          if (kDebugMode) {
            print(
                'Failed to get access token for FCM token registration (attempt $attempt/$maxRetries)');
          }
          continue;
        }

        // Determine device type
        final deviceType =
            defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';

        final Map<String, dynamic> requestBody = {
          'token': token,
          'device_type': deviceType,
        };

        if (kDebugMode) {
          print(
              'Registering device token (attempt $attempt/$maxRetries): ${token.substring(0, 10)}...');
        }

        final response = await http.post(
          Uri.parse('$apiEndpoint/messaging/register-device/'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode(requestBody),
        );

        // Success case - exit retry loop
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (kDebugMode) {
            print('FCM token successfully registered with backend');
          }
          return true;
        }

        // Check if we should retry based on status code
        if ((response.statusCode >= 400 && response.statusCode < 600) &&
            attempt < maxRetries) {
          if (kDebugMode) {
            print(
                'Retryable error (${response.statusCode}) registering FCM token. Attempt $attempt/$maxRetries');
            print('Response: ${response.body}');
          }
          // Wait before retrying - exponential backoff
          await Future.delayed(Duration(milliseconds: delayMs * attempt));
          continue;
        }

        // Non-retryable error or final attempt failed
        if (kDebugMode) {
          print(
              'Failed to register FCM token with backend: ${response.statusCode}');
          print('Response: ${response.body}');
        }
        break;
      } catch (e) {
        if (kDebugMode) {
          print(
              'Error registering FCM token with backend (attempt $attempt/$maxRetries): $e');
        }

        // Only retry on exceptions if we haven't hit max retries
        if (attempt < maxRetries) {
          await Future.delayed(Duration(milliseconds: delayMs * attempt));
          continue;
        }
      }
    }
    return false;
  }

  /// Helper method to get the access token
  Future<String?> _getAccessToken() async {
    try {
      final context = navigatorKey.currentContext;
      if (context == null) {
        if (kDebugMode) {
          print('No context available to get access token');
        }
        return null;
      }

      // Use the Provider to get the Auth0Provider
      final auth0Provider = Provider.of<Auth0Provider>(context, listen: false);
      final credentials = auth0Provider.credentials;
      return credentials?.accessToken;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting access token: $e');
      }
      return null;
    }
  }

  /// Load preferences from backend and populate the filters map
  Future<void> _loadPreferencesFromBackend() async {
    try {
      final prefs =
          await NotificationPreferencesService.instance.getPreferences();
      // Map each enum to its corresponding key in prefs
      for (final category in NotificationCategory.values) {
        final key = '${category.toString().split('.').last}_enabled';
        _notificationFilters[category] = prefs[key] ?? true;
      }
      if (kDebugMode) {
        print('Loaded notification preferences: $_notificationFilters');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading preferences from backend: $e');
      }
      // Default all to enabled
      for (final category in NotificationCategory.values) {
        _notificationFilters[category] = true;
      }
    }
  }
}
