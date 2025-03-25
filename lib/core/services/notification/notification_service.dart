import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:parsa/core/services/auth/auth0_class.dart';
import 'package:parsa/main.dart';
import 'package:provider/provider.dart';

class Notification {
  final String id;
  final String title;
  final String message;
  final String category;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic> data;

  Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.category,
    required this.isRead,
    required this.createdAt,
    required this.data,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      category: json['category'],
      isRead: json['is_read'],
      createdAt: DateTime.parse(json['created_at']),
      data: json['data'] ?? {},
    );
  }
}

class NotificationService {
  // Singleton instance
  static final NotificationService _instance = NotificationService._internal();

  // Factory constructor
  factory NotificationService() => _instance;

  // Internal constructor
  NotificationService._internal();

  // Static instance getter
  static NotificationService get instance => _instance;

  /// Get list of notifications for the current user
  Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int perPage = 20,
    bool unreadOnly = false,
  }) async {
    try {
      // Get access token
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token available');
      }

      // Prepare query parameters
      final queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
        'unread_only': unreadOnly.toString(),
      };

      // Make API request
      final uri = Uri.parse('$apiEndpoint/messaging/')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<Notification> notifications = (data['notifications'] as List)
            .map((item) => Notification.fromJson(item))
            .toList();

        return {
          'notifications': notifications,
          'pagination': data['pagination'],
        };
      } else {
        if (kDebugMode) {
          print('Failed to get notifications: ${response.statusCode}');
          print('Response: ${response.body}');
        }

        // Return empty list if API call fails
        return {
          'notifications': <Notification>[],
          'pagination': {
            'page': page,
            'per_page': perPage,
            'total': 0,
            'pages': 0,
          },
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting notifications: $e');
      }

      // Return empty list if error occurs
      return {
        'notifications': <Notification>[],
        'pagination': {
          'page': page,
          'per_page': perPage,
          'total': 0,
          'pages': 0,
        },
      };
    }
  }

  /// Delete a notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      // Get access token
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token available');
      }

      // Make API request
      final response = await http.delete(
        Uri.parse('$apiEndpoint/messaging/$notificationId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting notification: $e');
      }
      return false;
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
}
