import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:parsa/app/layout/tabs.dart';
import 'package:parsa/core/services/notification/notification_preferences_service.dart';
import 'package:parsa/core/services/notification/permission_service.dart';
import 'package:parsa/main.dart';
import '../../../firebase_options.dart';
import 'package:http/http.dart' as http;
import 'package:parsa/core/services/auth/auth0_class.dart';
import 'package:provider/provider.dart';
import 'package:parsa/core/routes/navigation_delegate.dart';
import 'package:parsa/core/api/fetch_user_transactions.dart';
import 'package:parsa/core/api/fetch_user_accounts.dart';

enum NotificationCategory {
  budgets,
  general,
  transactions,
  account,
}

// Top-level background message handler: must be a top-level function.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Need to ensure Firebase is initialized
  await Firebase.initializeApp();

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

  // Flag to track if FCM is initialized
  bool _isInitialized = false;

  // Flag to track if initialization is in progress to prevent concurrent calls
  bool _isInitializing = false;

  // Flag to track if token has been registered with server
  bool _isTokenRegistered = false;

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

        // Update notification preferences to reflect permission state
        await NotificationPreferencesService.instance.updatePreferences(
          budgetsEnabled: false,
          generalEnabled: false,
          transactionsEnabled: false,
          accountEnabled: false,
        );

        // Mark as initialized but exit early
        _isInitialized = true;
        _isInitializing = false;
        return;
      }

      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      // Listen for messages when the app is in the foreground.
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          print("Received a foreground message: ${message.messageId}");
          print('Message data: ${message.data}');
        }

        // Check if this is a reload notification
        if (message.data.containsKey('action') &&
            message.data['action'] == 'reload') {
          // Get current context
          final context = navigatorKey.currentContext;
          if (context != null) {
            _handleReloadAction(context);
          }
        }
      });

      // Listen for when a user taps on a notification (app opened via notification).
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('User tapped on notification: ${message.messageId}');
          print('Message data: ${message.data}');
        }

        // Handle reload action
        if (message.data.containsKey('action') &&
            message.data['action'] == 'reload') {
          // Handle reload action
          final context = navigatorKey.currentContext;
          if (context != null) {
            _handleReloadAction(context);
          }
          // Navigate to transactions
          NavigationDelegate.instance.navigateTo('/dashboard');
          return;
        }

        // Handle standard route navigation
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

      // Make sure FCM token is registered with the backend
      final token = await PermissionService.instance.getToken();
      if (token != null) {
        final success = await saveTokenToServer(token);
        _isTokenRegistered = success;

        if (kDebugMode) {
          print(_isTokenRegistered
              ? 'FCM token successfully registered with backend'
              : 'Failed to register FCM token with backend');
        }

        // Setup token refresh listener
        messaging.onTokenRefresh.listen((newToken) async {
          if (kDebugMode) {
            print('FCM Token refreshed: $newToken');
          }
          // Update our registered state
          _isTokenRegistered = await saveTokenToServer(newToken);
        });
      } else if (kDebugMode) {
        print('Failed to get FCM token during initialization');
      }

      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        if (kDebugMode) {
          print(
              'App was terminated and opened via notification: ${initialMessage.messageId}');
          print('Message data: ${initialMessage.data}');
        }

        // Handle reload action
        if (initialMessage.data.containsKey('action') &&
            initialMessage.data['action'] == 'reload') {
          // Handle reload action - context will be available after app is fully loaded
          Future.delayed(const Duration(seconds: 1), () {
            final context = navigatorKey.currentContext;
            if (context != null) {
              _handleReloadAction(context);
            }
            // Navigate to dashboard
            NavigationDelegate.instance.navigateTo('/dashboard');
          });
          return;
        }

        // Handle standard route navigation
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

      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        print("Error initializing FCM: $e");
      }
    } finally {
      _isInitializing = false;
    }
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

  // Centralized method that handles both permission request and FCM initialization
  Future<bool> requestPermissionAndInitialize() async {
    // Request permissions first
    final hasPermission =
        await PermissionService.instance.requestPermissionWithFCM();

    if (!hasPermission) {
      if (kDebugMode) {
        print("Notification permission denied by user");
      }

      // Update notification preferences to reflect permission state
      await NotificationPreferencesService.instance.updatePreferences(
        budgetsEnabled: false,
        generalEnabled: false,
        transactionsEnabled: false,
        accountEnabled: false,
      );

      return false;
    }

    // If permission granted, initialize FCM
    await initialize();

    // Register token with server
    await registerToken();

    return true;
  }

  // Handle reload action from notification data
  Future<void> _handleReloadAction(BuildContext? context) async {
    if (kDebugMode) {
      print("Handling reload action");
    }

    try {
      // Try to refresh data using TabsPage if available
      bool refreshedViaTabsPage = false;

      if (context != null) {
        // Find TabsPage ancestor by traversing up the widget tree
        TabsPageState? tabsPageState;

        // Look for TabsPage in the current context
        context.visitAncestorElements((element) {
          if (element.widget is TabsPage) {
            tabsPageState = element.findAncestorStateOfType<TabsPageState>();
            return false;
          }
          return true;
        });

        if (tabsPageState != null) {
          await tabsPageState!.refreshData(showLoading: false);
          refreshedViaTabsPage = true;
        }
      }

      // Fallback if TabsPage not found
      if (!refreshedViaTabsPage) {
        if (kDebugMode) {
          print("TabsPage not found, refreshing directly");
        }

        // First fetch accounts, then transactions
        await Future.wait([
          fetchUserAccounts(),
          fetchUserTransactions(null),
        ]);
      }

      // Show snackbar if context is available (foreground scenario)
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Dados atualizados com sucesso"),
            action: SnackBarAction(
              label: 'Ver',
              onPressed: () {
                // Navigate to dashboard as per user's change
                NavigationDelegate.instance.navigateTo('/dashboard');
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error handling reload action: $e");
      }

      // Show error snackbar if context is available
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Erro ao atualizar dados"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Register the FCM token for any service that needs it
  Future<bool> registerToken() async {
    // If not initialized, try to initialize first
    if (!_isInitialized) {
      if (kDebugMode) {
        print(
            'FCM not initialized, attempting to initialize before registering token');
      }

      try {
        await initialize();
        // If initialization failed, return false
        if (!_isInitialized) {
          if (kDebugMode) {
            print('Cannot register token: FCM initialization failed');
          }
          return false;
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error initializing FCM before token registration: $e');
        }
        return false;
      }
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

  // Method to handle when permissions are granted
  Future<bool> handlePermissionGranted() async {
    if (kDebugMode) {
      print('FCM: Permission granted, initializing and registering token');
    }

    // Reset initialization state
    resetInitializationState();

    // Initialize FCM
    await initialize();

    // Register token with server and retry if it fails
    bool result = await registerToken();

    // Retry registration if it failed on first attempt
    if (!result) {
      if (kDebugMode) {
        print('First token registration failed, retrying after short delay...');
      }

      // Wait a short time and try again
      await Future.delayed(const Duration(milliseconds: 500));
      result = await registerToken();

      if (kDebugMode) {
        print(result
            ? 'Token registration succeeded on retry'
            : 'Token registration failed even after retry');
      }
    }

    return result;
  }
}
