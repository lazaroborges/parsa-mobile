import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:parsa/core/routes/destinations.dart';
import 'package:parsa/core/services/permission_service.dart';
import 'package:parsa/main.dart'; // Import for navigatorKey
import '../../firebase_options.dart';
import 'package:http/http.dart' as http;
import 'package:parsa/core/services/auth/auth0_class.dart';
import 'package:provider/provider.dart';

// Define notification categories
enum NotificationCategory {
  transactions,
  budgets,
  accounts,
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

  // Notification filters
  final Map<NotificationCategory, bool> _notificationFilters = {
    NotificationCategory.transactions: true,
    NotificationCategory.budgets: true,
    NotificationCategory.accounts: true,
    NotificationCategory.general: true,
  };

  // Get notification filter status
  bool getNotificationFilter(NotificationCategory category) {
    return _notificationFilters[category] ?? true;
  }

  // Set notification filter
  void setNotificationFilter(NotificationCategory category, bool enabled) {
    _notificationFilters[category] = enabled;
    // You could persist these settings in shared preferences
  }

  Future<void> initialize() async {
    // Prevent multiple initializations
    if (_isInitialized) return;

    // If Firebase is not yet initialized, initialize it.
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
    }

    // Request Android notification permissions using permission_handler
    await PermissionService.instance.requestNotificationPermission();

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

      // Apply notification filtering
      if (_shouldShowNotification(message)) {
        // Show the notification if it passes our filters
        _showForegroundNotification(message);
      }
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

    // Get the FCM token
    await getToken();

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

  // Show a foreground notification
  void _showForegroundNotification(RemoteMessage message) {
    // This is where you would implement custom foreground notifications
    // For example with flutter_local_notifications plugin
    // This is a placeholder - in your actual implementation you would show a local notification
  }

  // Apply notification filters
  bool _shouldShowNotification(RemoteMessage message) {
    // Check if notification has a category in data
    if (message.data.containsKey('category')) {
      final category = _getCategoryFromString(message.data['category']);
      return getNotificationFilter(category);
    }

    // If no category specified, check based on route
    if (message.data.containsKey('route')) {
      final route = message.data['route'];
      switch (route) {
        case 'transactions':
          return getNotificationFilter(NotificationCategory.transactions);
        case 'budgets':
          return getNotificationFilter(NotificationCategory.budgets);
        case 'accounts':
          return getNotificationFilter(NotificationCategory.accounts);
        default:
          return getNotificationFilter(NotificationCategory.general);
      }
    }

    // Default to showing general notifications
    return getNotificationFilter(NotificationCategory.general);
  }

  // Helper to convert string to NotificationCategory
  NotificationCategory _getCategoryFromString(String? category) {
    switch (category) {
      case 'transactions':
        return NotificationCategory.transactions;
      case 'budgets':
        return NotificationCategory.budgets;
      case 'accounts':
        return NotificationCategory.accounts;
      default:
        return NotificationCategory.general;
    }
  }

  // Subscribe to topics based on enabled notification filters
  Future<void> _subscribeToTopics() async {
    // Subscribe to general notifications
    if (_notificationFilters[NotificationCategory.general] ?? true) {
      await messaging.subscribeToTopic('general');
    } else {
      await messaging.unsubscribeFromTopic('general');
    }

    // Subscribe to transactions notifications
    if (_notificationFilters[NotificationCategory.transactions] ?? true) {
      await messaging.subscribeToTopic('transactions');
    } else {
      await messaging.unsubscribeFromTopic('transactions');
    }

    // Subscribe to budgets notifications
    if (_notificationFilters[NotificationCategory.budgets] ?? true) {
      await messaging.subscribeToTopic('budgets');
    } else {
      await messaging.unsubscribeFromTopic('budgets');
    }

    // Subscribe to accounts notifications
    if (_notificationFilters[NotificationCategory.accounts] ?? true) {
      await messaging.subscribeToTopic('accounts');
    } else {
      await messaging.unsubscribeFromTopic('accounts');
    }

    if (kDebugMode) {
      print('Subscribed to FCM topics based on user preferences');
    }
  }

  // Update notification preferences and resubscribe to topics
  Future<void> updateNotificationPreferences(
      Map<NotificationCategory, bool> preferences) async {
    // Update filters
    preferences.forEach((key, value) {
      _notificationFilters[key] = value;
    });

    // Resubscribe to topics based on new preferences
    await _subscribeToTopics();
  }

  /// Handle navigation based on notification data
  void _handleNotificationNavigation(RemoteMessage message) {
    // Only navigate if we have a navigator key and the app is initialized
    if (navigatorKey.currentState == null) return;

    try {
      // Check if the message contains a route to navigate to
      if (message.data.containsKey('route')) {
        final String route = message.data['route'] as String;

        // Simple switch to handle different routes
        switch (route) {
          case 'transactions':
            // Navigate to transactions page - You'll need to implement these navigation methods
            _navigateToTransactions();
            break;
          case 'budgets':
            // Navigate to budgets page
            _navigateToBudgets();
            break;
          case 'accounts':
            // Navigate to accounts page
            _navigateToAccounts();
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

  void _navigateToTransactions() {
    // Navigate to transactions screen - first ensure we're on the main tabs page
    final context = navigatorKey.currentContext;
    if (context != null && tabsPageKey.currentState != null) {
      // Get destinations from the tabs page and find the transactions destination
      final destinations = getDestinations(context, shortLabels: false);
      final transactionsDestination = destinations.firstWhere(
        (dest) => dest.id == 'transactions',
        orElse: () => destinations.first,
      );

      // Change to the transactions tab
      tabsPageKey.currentState?.changePage(transactionsDestination);
    }
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

  void _navigateToAccounts() {
    // Navigate to accounts screen - first ensure we're on the main tabs page
    final context = navigatorKey.currentContext;
    if (context != null && tabsPageKey.currentState != null) {
      // Get destinations from the tabs page and find the accounts destination
      final destinations = getDestinations(context, shortLabels: false);
      final accountsDestination = destinations.firstWhere(
        (dest) => dest.id == 'accounts',
        orElse: () => destinations.first,
      );

      // Change to the accounts tab
      tabsPageKey.currentState?.changePage(accountsDestination);
    }
  }

  /// Get the FCM token for this device
  Future<String?> getToken() async {
    _fcmToken = await messaging.getToken();

    if (kDebugMode && _fcmToken != null) {
      print('FCM Token: $_fcmToken');
    }

    // Set up token refresh listener
    messaging.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      if (kDebugMode) {
        print('FCM Token refreshed: $_fcmToken');
      }
      // Here you would typically send the new token to your server
      saveTokenToServer(newToken);
    });

    return _fcmToken;
  }

  /// Delete the FCM token
  Future<void> deleteToken() async {
    await messaging.deleteToken();
    _fcmToken = null;
    if (kDebugMode) {
      print('FCM Token deleted');
    }
  }

  /// Save the FCM token to your backend server
  Future<void> saveTokenToServer(String? token) async {
    if (token == null) return;

    try {
      // Get access token from Auth0Provider
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        if (kDebugMode) {
          print('Failed to get access token for FCM token registration');
        }
        return;
      }

      // Determine device type
      final deviceType =
          defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';

      // Send the token to your Django backend
      final response = await http.post(
        Uri.parse('$apiEndpoint/api/notifications/register-device/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'token': token,
          'device_type': deviceType,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (kDebugMode) {
          print('FCM token successfully registered with backend');
        }
      } else {
        if (kDebugMode) {
          print(
              'Failed to register FCM token with backend: ${response.statusCode}');
          print('Response: ${response.body}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error registering FCM token with backend: $e');
      }
    }
  }

  /// Sync notification preferences with the backend
  Future<void> syncNotificationPreferencesWithBackend() async {
    try {
      // Get access token from Auth0Provider
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        if (kDebugMode) {
          print(
              'Failed to get access token for syncing notification preferences');
        }
        return;
      }

      // Send the preferences to your Django backend
      final response = await http.post(
        Uri.parse('$apiEndpoint/api/notifications/update-preferences/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'transactions_enabled':
              _notificationFilters[NotificationCategory.transactions] ?? true,
          'budgets_enabled':
              _notificationFilters[NotificationCategory.budgets] ?? true,
          'accounts_enabled':
              _notificationFilters[NotificationCategory.accounts] ?? true,
          'general_enabled':
              _notificationFilters[NotificationCategory.general] ?? true,
        }),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Notification preferences successfully synced with backend');
        }
      } else {
        if (kDebugMode) {
          print(
              'Failed to sync notification preferences with backend: ${response.statusCode}');
          print('Response: ${response.body}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing notification preferences with backend: $e');
      }
    }
  }

  /// Helper method to get the access token
  Future<String?> _getAccessToken() async {
    try {
      // Use Provider to get the Auth0Provider instance
      // Since we can't directly access the Provider here, we'll use a simpler approach
      // by accessing the credentials manager directly from the main navigator context

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

  /// Trigger a manual test notification from the backend
  Future<bool> triggerTestNotification({
    required String title,
    required String body,
    required NotificationCategory category,
    String? route,
    Map<String, dynamic>? additionalData,
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
      final categoryStr = category.toString().split('.').last;

      // Prepare request data
      final data = {
        'title': title,
        'body': body,
        'category': categoryStr,
        'send_to_token': _fcmToken,
        'data': {
          'category': categoryStr,
          'route': route ?? categoryStr,
          ...?additionalData,
        }
      };

      if (kDebugMode) {
        print('Sending test notification request: $data');
      }

      // Send request to backend
      final response = await http.post(
        Uri.parse('$apiEndpoint/api/notifications/send-test/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Test notification triggered successfully');
          print('Response: ${response.body}');
        }
        return true;
      } else {
        if (kDebugMode) {
          print('Failed to trigger test notification: ${response.statusCode}');
          print('Response: ${response.body}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error triggering test notification: $e');
      }
      return false;
    }
  }

  /// Trigger test notifications for each category
  Future<List<bool>> triggerAllCategoryTestNotifications() async {
    final results = <bool>[];

    // Test transactions notification
    results.add(await triggerTestNotification(
      title: 'Lembrete de Transação',
      body: 'Não se esqueça de registrar suas transações de hoje!',
      category: NotificationCategory.transactions,
      additionalData: {'transaction_id': 'test_123'},
    ));

    // Test budgets notification
    results.add(await triggerTestNotification(
      title: 'Alerta de Orçamento',
      body: 'Você atingiu 80% do seu orçamento mensal de Alimentação.',
      category: NotificationCategory.budgets,
      additionalData: {'budget_id': 'budget_123'},
    ));

    // Test accounts notification
    results.add(await triggerTestNotification(
      title: 'Atualização de Conta',
      body: 'Seus dados financeiros foram atualizados com sucesso!',
      category: NotificationCategory.accounts,
      additionalData: {'account_id': 'account_123'},
    ));

    // Test general notification
    results.add(await triggerTestNotification(
      title: 'Dica Financeira',
      body: 'Economize mais dinheiro configurando metas mensais!',
      category: NotificationCategory.general,
    ));

    return results;
  }

  /// Fetch notifications from the backend
  Future<Map<String, dynamic>> fetchNotifications({
    int page = 1,
    int perPage = 20,
    bool unreadOnly = false,
  }) async {
    try {
      // Get access token from Auth0Provider
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        if (kDebugMode) {
          print('Failed to get access token for fetching notifications');
        }
        return {'error': 'Authentication failed'};
      }

      // Build query parameters
      final queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
        'unread_only': unreadOnly.toString(),
      };

      // Send request to backend
      final response = await http.get(
        Uri.parse('$apiEndpoint/api/notifications/list-notifications/').replace(
          queryParameters: queryParams,
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Notifications fetched successfully');
        }

        // Parse and return the response
        return jsonDecode(response.body);
      } else {
        if (kDebugMode) {
          print('Failed to fetch notifications: ${response.statusCode}');
          print('Response: ${response.body}');
        }
        return {'error': 'Failed to fetch notifications'};
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching notifications: $e');
      }
      return {'error': e.toString()};
    }
  }

  /// Mark a notification as read
  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      // Get access token from Auth0Provider
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        if (kDebugMode) {
          print('Failed to get access token for marking notification as read');
        }
        return false;
      }

      // Send request to backend
      final response = await http.post(
        Uri.parse(
            '$apiEndpoint/api/notifications/mark-as-read/$notificationId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Notification marked as read successfully');
        }
        return true;
      } else {
        if (kDebugMode) {
          print('Failed to mark notification as read: ${response.statusCode}');
          print('Response: ${response.body}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error marking notification as read: $e');
      }
      return false;
    }
  }

  /// Mark all notifications as read
  Future<bool> markAllNotificationsAsRead() async {
    try {
      // Get access token from Auth0Provider
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        if (kDebugMode) {
          print(
              'Failed to get access token for marking all notifications as read');
        }
        return false;
      }

      // Send request to backend
      final response = await http.post(
        Uri.parse('$apiEndpoint/api/notifications/mark-as-read/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('All notifications marked as read successfully');
        }
        return true;
      } else {
        if (kDebugMode) {
          print(
              'Failed to mark all notifications as read: ${response.statusCode}');
          print('Response: ${response.body}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error marking all notifications as read: $e');
      }
      return false;
    }
  }

  /// Delete a notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      // Get access token from Auth0Provider
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        if (kDebugMode) {
          print('Failed to get access token for deleting notification');
        }
        return false;
      }

      // Send request to backend
      final response = await http.delete(
        Uri.parse(
            '$apiEndpoint/api/notifications/delete-notification/$notificationId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Notification deleted successfully');
        }
        return true;
      } else {
        if (kDebugMode) {
          print('Failed to delete notification: ${response.statusCode}');
          print('Response: ${response.body}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting notification: $e');
      }
      return false;
    }
  }
}
