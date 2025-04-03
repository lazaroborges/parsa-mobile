import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:parsa/core/services/notification/notification_preferences_service.dart';
import 'package:parsa/core/routes/destinations.dart';
import 'package:parsa/core/services/notification/permission_service.dart';
import 'package:parsa/main.dart'; // Import for navigatorKey
import '../../../firebase_options.dart';
import 'package:http/http.dart' as http;
import 'package:parsa/core/services/auth/auth0_class.dart';
import 'package:provider/provider.dart';

// Define notification categories - simplified to only two categories
enum NotificationCategory {
  budgets,
  general,
}

// Top-level background message handler: must be a top-level function.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized in background.
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

  // FCM token
  String? _fcmToken;

  // Getter for the FCM token
  String? get fcmToken => _fcmToken;

  // Flag to track if FCM is initialized
  bool _isInitialized = false;

  // Notification filters - simplified to just two categories
  final Map<NotificationCategory, bool> _notificationFilters = {
    NotificationCategory.budgets: true,
    NotificationCategory.general: true,
  };

  // Get notification filter status
  bool getNotificationFilter(NotificationCategory category) {
    return _notificationFilters[category] ?? true;
  }

  // Set notification filter
  Future<bool> setNotificationFilter(
      NotificationCategory category, bool enabled) async {
    // Update the internal map
    _notificationFilters[category] = enabled;

    // Update subscription immediately
    await _updateTopicSubscription(category, enabled);

    // Update backend preference
    bool success = false;
    switch (category) {
      case NotificationCategory.budgets:
        success = await NotificationPreferencesService.instance
            .updatePreferences(budgetsEnabled: enabled);
        break;
      case NotificationCategory.general:
        success = await NotificationPreferencesService.instance
            .updatePreferences(generalEnabled: enabled);
        break;
    }

    return enabled;
  }

  // Master toggle for all notifications
  Future<bool> setNotificationsEnabled(bool enabled) async {
    for (var category in NotificationCategory.values) {
      // Update the internal map
      _notificationFilters[category] = enabled;

      await _updateTopicSubscription(category, enabled);
    }

    await NotificationPreferencesService.instance.updatePreferences(
      budgetsEnabled: enabled,
      generalEnabled: enabled,
    );

    if (kDebugMode) {
      print('All notifications ${enabled ? 'enabled' : 'disabled'}');
    }

    return enabled;
  }

  // Check if notifications are enabled overall
  Future<bool> getNotificationsEnabled() async {
    final prefs =
        await NotificationPreferencesService.instance.getPreferences();
    // Consider notifications enabled if any category is enabled
    return prefs['budgets_enabled'] == true || prefs['general_enabled'] == true;
  }

  Future<void> initialize() async {
    // Prevent multiple initializations
    if (_isInitialized) return;

    // If Firebase is not yet initialized, initialize it.
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
    }

    // Request permissions using PermissionService
    bool hasPermission = await PermissionService.instance.prepareForFCMToken();

    if (!hasPermission) {
      if (kDebugMode) {
        print("FCM initialization: User denied notification permissions");
      }
      // Mark as initialized but exit early - don't proceed with FCM setup
      _isInitialized = true;
      return;
    }

    // Request permission on iOS (alerts, badge, sound).
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );

    if (kDebugMode) {
      print("FCM permission status: ${settings.authorizationStatus}");
    }

    // Exit if permission is denied
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      if (kDebugMode) {
        print("FCM initialization stopped: Permission denied");
      }
      _isInitialized = true;
      return;
    }

    // Register the background message handler.
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Listen for messages when the app is in the foreground.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print("Received a foreground message: ${message.messageId}");
        if (message.notification != null) {
          print('Notification title: ${message.notification?.title}');
          print('Notification body: ${message.notification?.body}');
        }
      }

      // Store the message data for displaying in the app
      // This would be handled by a notification display service in a real app
    });

    // Listen for when a user taps on a notification (app opened via notification).
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('User tapped on notification: ${message.messageId}');
        print('Message data: ${message.data}');
      }

      // Handle notification navigation
      _handleNotificationNavigation(message);
    });

    // Get the FCM token and register it with backend
    await getToken().then((token) {
      if (token != null) {
        saveTokenToServer(token);
      }
    });

    // Load preferences from the backend and update internal map
    await _loadPreferencesFromBackend();

    // Subscribe to topics based on enabled notification categories
    await _subscribeToTopics();

    // Set up background message handler for when app is terminated
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      if (kDebugMode) {
        print(
            'App was terminated and opened via notification: ${initialMessage.messageId}');
      }

      // Handle notification navigation for app opened from terminated state
      _handleNotificationNavigation(initialMessage);
    }

    // Configure FCM to use APNS tokens on iOS
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    _isInitialized = true;
  }

  // Load preferences from backend and update local filters
  Future<void> _loadPreferencesFromBackend() async {
    try {
      final prefs =
          await NotificationPreferencesService.instance.getPreferences();

      // Update internal notification filters
      _notificationFilters[NotificationCategory.budgets] =
          prefs['budgets_enabled'] ?? true;
      _notificationFilters[NotificationCategory.general] =
          prefs['general_enabled'] ?? true;

      if (kDebugMode) {
        print('Loaded notification preferences from backend:');
        print('budgets_enabled: ${prefs['budgets_enabled']}');
        print('general_enabled: ${prefs['general_enabled']}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading preferences from backend: $e');
        print('Using default notification preferences');
      }

      // Use defaults if loading fails
      _notificationFilters[NotificationCategory.budgets] = true;
      _notificationFilters[NotificationCategory.general] = true;
    }
  }

  // Subscribe to topics based on enabled notification filters
  Future<void> _subscribeToTopics() async {
    // Subscribe to general notifications
    await _updateTopicSubscription(NotificationCategory.general,
        _notificationFilters[NotificationCategory.general] ?? true);

    // Subscribe to budgets notifications
    await _updateTopicSubscription(NotificationCategory.budgets,
        _notificationFilters[NotificationCategory.budgets] ?? true);

    if (kDebugMode) {
      print('Subscribed to FCM topics based on user preferences');
    }
  }

  // Helper method to update a single topic subscription
  Future<void> _updateTopicSubscription(
      NotificationCategory category, bool isEnabled) async {
    final topicName = category.toString().split('.').last;

    // Check current state from our in-memory map to avoid unnecessary API calls
    final currentlySubscribed = _notificationFilters[category] ?? false;

    // Only make API calls if the subscription state is changing
    if (isEnabled != currentlySubscribed) {
      if (isEnabled) {
        await messaging.subscribeToTopic(topicName);
        if (kDebugMode) {
          print('Subscribed to topic: $topicName');
        }
      } else {
        await messaging.unsubscribeFromTopic(topicName);
        if (kDebugMode) {
          print('Unsubscribed from topic: $topicName');
        }
      }

      // Update our in-memory map with the new state
      _notificationFilters[category] = isEnabled;
    }
  }

  /// Handle navigation based on notification data
  void _handleNotificationNavigation(RemoteMessage message) {
    // Only navigate if we have a navigator key and the app is initialized
    if (navigatorKey.currentState == null) return;

    try {
      // Check if the message contains a route to navigate to
      if (message.data.containsKey('route')) {
        final String route = message.data['route'] as String;

        // Simple switch to handle different routes - only keeping budgets and home
        switch (route) {
          case 'budgets':
            // Navigate to budgets page
            _navigateToBudgets();
            break;
          default:
            // If no specific route, just ensure we're on the main tabs page
            _navigateToHome();
            break;
        }
      } else {
        // Default navigation if no specific route is specified
        _navigateToHome();
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error navigating from notification: $e");
      }
    }
  }

  // Navigation helper methods
  void _navigateToHome() {
    // Navigate to home/main screen
    navigatorKey.currentState?.pushNamedAndRemoveUntil('/', (route) => false);
  }

  void _navigateToBudgets() {
    // Navigate to budgets screen - first ensure we're on the main tabs page
    final context = navigatorKey.currentContext;
    if (context != null && tabsPageKey.currentState != null) {
      // Get destinations from the tabs page and find the budgets destination
      final destinations = getDestinations(context, shortLabels: false);
      final budgetsDestination = destinations.firstWhere(
        (dest) => dest.id == 'budgets',
        orElse: () => destinations.first,
      );

      // Change to the budgets tab
      tabsPageKey.currentState?.changePage(budgetsDestination);
    }
  }

  /// Get the FCM token for this device
  Future<String?> getToken() async {
    _fcmToken = await messaging.getToken();

    if (kDebugMode && _fcmToken != null) {
      print('FCM Token: $_fcmToken');
    }

    // Set up token refresh listener
    messaging.onTokenRefresh.listen((newToken) async {
      _fcmToken = newToken;
      if (kDebugMode) {
        print('FCM Token refreshed: $_fcmToken');
      }

      // Save the new token to server
      await saveTokenToServer(newToken);
    });

    return _fcmToken;
  }

  /// Save the FCM token to your backend server with retry logic
  Future<void> saveTokenToServer(String? token,
      {int maxRetries = 3, int delayMs = 1000}) async {
    if (token == null) return;

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
              'Registering device token (attempt $attempt/$maxRetries): $requestBody');
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
          return;
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

  /// Trigger a test notification for testing
  Future<bool> triggerTestNotification({
    required String title,
    required String body,
    required NotificationCategory category,
  }) async {
    try {
      // Get access token from Auth0Provider
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        if (kDebugMode) {
          print('Failed to get access token for sending test notification');
        }
        return false;
      }

      // Convert category to string format expected by backend
      final categoryStr = category.toString().split('.').last.toLowerCase();

      // Prepare request data - simplified to essential fields only
      final data = {
        'title': title,
        'body': body,
        'category': categoryStr,
        'data': {
          'category': categoryStr,
          'route': categoryStr,
        }
      };

      if (kDebugMode) {
        print('Sending test notification request: $data');
      }

      // Send request to backend using the new unified endpoint
      final response = await http.post(
        Uri.parse('$apiEndpoint/messaging/send/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode != 202) {
        if (kDebugMode) {
          print('Failed to send test notification: ${response.statusCode}');
          print('Response: ${response.body}');
        }
        return false;
      }

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error triggering test notification: $e');
      }
      return false;
    }
  }
}
