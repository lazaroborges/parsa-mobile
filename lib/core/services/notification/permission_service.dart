import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class PermissionService {
  // Singleton instance
  static final PermissionService _instance = PermissionService._internal();

  // Factory constructor
  factory PermissionService() => _instance;

  // Private constructor
  PermissionService._internal();

  // Getter for the singleton instance
  static PermissionService get instance => _instance;

  /// Request notification permissions
  Future<bool> requestNotificationPermission() async {
    if (Platform.isAndroid) {
      return _requestAndroidNotificationPermission();
    } else if (Platform.isIOS) {
      return await Permission.notification.request().isGranted;
    }
    return false;
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
      return await Permission.notification.isGranted;
    }
    return false;
  }

  /// Prepare device for FCM token retrieval by ensuring all required permissions
  Future<bool> prepareForFCMToken() async {
    if (Platform.isAndroid) {
      final hasPermission = await hasNotificationPermission();

      if (!hasPermission) {
        return await requestNotificationPermission();
      }
      return true;
    } else if (Platform.isIOS) {
      return await Permission.notification.request().isGranted;
    }
    return false;
  }
}
