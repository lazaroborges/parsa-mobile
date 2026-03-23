import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PermissionService {
  // Singleton instance
  static final PermissionService _instance = PermissionService._internal();

  // Factory constructor
  factory PermissionService() => _instance;

  // Private constructor
  PermissionService._internal();

  // Getter for the singleton instance
  static PermissionService get instance => _instance;

  // Store FCM token to avoid multiple retrievals
  String? _fcmToken;
  String? _apnsToken;

  // Get the iOS APNs token
  Future<String?> getAPNSToken() async {
    if (!Platform.isIOS) return null;

    try {
      final messaging = FirebaseMessaging.instance;
      _apnsToken = await messaging.getAPNSToken();

      if (kDebugMode) {
        print('APNs Token: $_apnsToken');
      }

      return _apnsToken;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting APNs token: $e');
      }
      return null;
    }
  }

  // Get FCM token following the codelab example
  Future<String?> getToken() async {
    if (_fcmToken != null) return _fcmToken;

    try {
      final messaging = FirebaseMessaging.instance;

      // On iOS, ensure remote notifications are registered and APNs token is available
      if (Platform.isIOS) {
        // requestPermission() triggers registerForRemoteNotifications() on iOS,
        // which is needed every app launch for the APNs token to be delivered
        await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );

        // Wait for APNs token to arrive
        String? apnsToken;
        for (int i = 0; i < 10; i++) {
          apnsToken = await messaging.getAPNSToken();
          if (apnsToken != null) break;
          await Future.delayed(const Duration(seconds: 1));
        }
        if (apnsToken == null) {
          if (kDebugMode) {
            print('APNs token not available after waiting');
          }
          return null;
        }
      }

      // Request a registration token for sending messages to users
      _fcmToken = await messaging.getToken();

      if (kDebugMode) {
        print('Registration Token=$_fcmToken');
      }

      return _fcmToken;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting FCM token: $e');
      }
      return null;
    }
  }

  /// Centralized method to request notification permissions on both Android and iOS
  Future<bool> requestNotifications() async {
    if (Platform.isAndroid) {
      return _requestAndroidNotificationPermission();
    } else if (Platform.isIOS) {
      return _requestIOSNotificationPermission();
    }
    return false;
  }

  /// Request notification permissions - legacy method for compatibility
  Future<bool> requestNotificationPermission() async {
    return requestNotifications();
  }

  /// Request notification permission for Android
  Future<bool> _requestAndroidNotificationPermission() async {
    // For Android 13 (API level 33) and higher, we need to request POST_NOTIFICATIONS permission
    if (await _isAndroid13OrHigher()) {
      final status = await Permission.notification.request();

      if (kDebugMode) {
        print('Android notification permission status: $status');
      }

      return status.isGranted;
    }

    // For Android 12 and lower, no explicit permission is needed
    return true;
  }

  /// Request notification permission following the codelab example
  Future<bool> requestPermissionWithFCM() async {
    try {
      final messaging = FirebaseMessaging.instance;

      // Request permission as shown in the codelab
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (kDebugMode) {
        print('Permission granted: ${settings.authorizationStatus}');
      }

      // Get token after permission is granted
      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        await getToken();

        // For iOS, also get the APNS token
        if (Platform.isIOS) {
          await getAPNSToken();
        }
      }

      // Return true if permission granted
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting notification permissions: $e');
      }
      return false;
    }
  }

  /// Request notification permission for iOS using Firebase Messaging
  Future<bool> _requestIOSNotificationPermission() async {
    try {
      final messaging = FirebaseMessaging.instance;

      // Configure presentation options for iOS
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Request iOS notification permissions
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (kDebugMode) {
        print(
            'iOS Notification permission status: ${settings.authorizationStatus}');
      }

      // Get APNS token after permission is granted
      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        await getAPNSToken();
      }

      // Check if permission was granted
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting iOS notification permissions: $e');
      }
      return false;
    }
  }

  /// Check if the device is running Android 13 (API level 33) or higher
  Future<bool> _isAndroid13OrHigher() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt >= 33;
    }
    return false;
  }

  /// Check if notification permission is granted
  Future<bool> hasNotificationPermission() async {
    if (Platform.isAndroid) {
      if (await _isAndroid13OrHigher()) {
        return await Permission.notification.isGranted;
      }
      return true;
    } else if (Platform.isIOS) {
      try {
        final messaging = FirebaseMessaging.instance;
        final settings = await messaging.getNotificationSettings();
        return settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;
      } catch (e) {
        if (kDebugMode) {
          print('Error checking iOS notification permission: $e');
        }
        return false;
      }
    }
    return false;
  }

  /// Prepare device for FCM token retrieval by ensuring all required permissions
  Future<bool> prepareForFCMToken() async {
    final hasPermission = await hasNotificationPermission();
    if (!hasPermission) {
      return await requestPermissionWithFCM();
    }
    return true;
  }
}
