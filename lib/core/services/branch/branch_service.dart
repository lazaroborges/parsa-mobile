import 'package:flutter/foundation.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';

class BranchService {
  static final BranchService instance = BranchService._();
  BranchService._();

  /// Creates a Branch Universal Object for content sharing
  Future<BranchUniversalObject> createBranchUniversalObject({
    required String identifier,
    required String title,
    String? imageUrl,
    String? description,
    List<String>? keywords,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final buo = BranchUniversalObject(
        canonicalIdentifier: identifier,
        title: title,
        imageUrl: imageUrl ?? '',
        contentDescription: description ?? '',
        keywords: keywords ?? [],
        publiclyIndex: true,
        locallyIndex: true,
      );

      if (metadata != null) {
        final contentMetadata = BranchContentMetaData();
        metadata.forEach((key, value) {
          contentMetadata.addCustomMetadata(key, value);
        });
        buo.contentMetadata = contentMetadata;
      }

      return buo;
    } catch (e) {
      debugPrint('Error creating Branch Universal Object: $e');
      rethrow;
    }
  }

  /// Creates Branch link properties for deep linking
  BranchLinkProperties createLinkProperties({
    String? channel,
    String? feature,
    String? stage,
    List<String>? tags,
    Map<String, String>? controlParams,
  }) {
    try {
      final linkProperties = BranchLinkProperties(
        channel: channel ?? '',
        feature: feature ?? '',
        stage: stage ?? '',
        tags: tags ?? [],
      );

      if (controlParams != null) {
        controlParams.forEach((key, value) {
          linkProperties.addControlParam(key, value);
        });
      }

      return linkProperties;
    } catch (e) {
      debugPrint('Error creating Branch Link Properties: $e');
      rethrow;
    }
  }

  /// Generates a Branch deep link
  Future<String?> generateDeepLink({
    required BranchUniversalObject universalObject,
    required BranchLinkProperties linkProperties,
  }) async {
    try {
      final response = await FlutterBranchSdk.getShortUrl(
        buo: universalObject,
        linkProperties: linkProperties,
      );

      if (!response.success) {
        debugPrint('Branch link creation failed: ${response.errorMessage}');
        return null;
      }

      debugPrint('Branch link created successfully: ${response.result}');
      return response.result;
    } catch (e) {
      debugPrint('Error generating Branch deep link: $e');
      return null;
    }
  }

  /// Retrieves the latest referring parameters
  Future<Map<dynamic, dynamic>> getLatestReferringParams() async {
    try {
      final params = await FlutterBranchSdk.getLatestReferringParams();
      debugPrint('Latest referring params: $params');
      return params;
    } catch (e) {
      debugPrint('Error getting latest referring params: $e');
      return {};
    }
  }

  /// Retrieves the first referring parameters (install only)
  Future<Map<dynamic, dynamic>> getFirstReferringParams() async {
    try {
      final params = await FlutterBranchSdk.getFirstReferringParams();
      debugPrint('First referring params: $params');
      return params;
    } catch (e) {
      debugPrint('Error getting first referring params: $e');
      return {};
    }
  }

  /// Gets the last attributed touch data
  Future<Map<String, dynamic>?> getLastAttributedTouchData() async {
    try {
      final response = await FlutterBranchSdk.getLastAttributedTouchData();
      if (!response.success) {
        debugPrint(
            'Failed to get last attributed touch data: ${response.errorMessage}');
        return null;
      }
      return response.result as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error getting last attributed touch data: $e');
      return null;
    }
  }

  /// Set identity for the current user
  Future<void> setUserIdentity(String userId) async {
    try {
      FlutterBranchSdk.setIdentity(userId);
      debugPrint('Branch identity set for user: $userId');
    } catch (e) {
      debugPrint('Error setting Branch identity: $e');
      rethrow;
    }
  }

  /// Check if a user identity is set
  Future<bool> isUserIdentified() async {
    try {
      return await FlutterBranchSdk.isUserIdentified();
    } catch (e) {
      debugPrint('Error checking user identification: $e');
      return false;
    }
  }

  /// Logout the current user
  void logout() {
    try {
      FlutterBranchSdk.logout();
      debugPrint('Branch user logged out');
    } catch (e) {
      debugPrint('Error logging out Branch user: $e');
      rethrow;
    }
  }

  /// Handle a deep link manually
  void handleDeepLink(String url) {
    try {
      FlutterBranchSdk.handleDeepLink(url);
      debugPrint('Handled deep link: $url');
    } catch (e) {
      debugPrint('Error handling deep link: $e');
      rethrow;
    }
  }

  /// Set request metadata for partner integrations
  void setRequestMetadata(String key, String value) {
    try {
      FlutterBranchSdk.setRequestMetadata(key, value);
      debugPrint('Set request metadata - Key: $key, Value: $value');
    } catch (e) {
      debugPrint('Error setting request metadata: $e');
      rethrow;
    }
  }

  /// Disable tracking for GDPR compliance
  void disableTracking(bool disable) {
    try {
      FlutterBranchSdk.disableTracking(disable);
      debugPrint('Branch tracking ${disable ? 'disabled' : 'enabled'}');
    } catch (e) {
      debugPrint('Error setting tracking status: $e');
      rethrow;
    }
  }
}
