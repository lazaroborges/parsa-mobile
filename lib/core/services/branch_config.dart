import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';

class BranchConfig {
  static Future<void> initialize() async {
    // Initialize Branch
    await FlutterBranchSdk.init(
      useTestKey: false, // Set to true for development
      enableLogging: true, // Set to false in production
    );

    // Listen to deep links
    FlutterBranchSdk.listSession().listen((data) {
      if (data.containsKey('+clicked_branch_link') &&
          data['+clicked_branch_link'] == true) {
        // Handle the deep link
        _handleBranchDeepLink(data);
      }
    });
  }

  static void _handleBranchDeepLink(Map<dynamic, dynamic> linkData) {
    // Extract deep link data
    final String? path = linkData['\$deeplink_path'];
    final Map<dynamic, dynamic>? params = linkData['custom_data'];

    if (path != null) {
      switch (path) {
        case 'accounts':
          final String? accountId = params?['id'];
          if (accountId != null) {
            goRouter.go('/accounts/$accountId');
          } else {
            goRouter.go('/accounts');
          }
          break;
        case 'transactions':
          final String? transactionId = params?['id'];
          if (transactionId != null) {
            goRouter.go('/transactions/$transactionId');
          } else {
            goRouter.go('/transactions');
          }
          break;
        // Add other cases as needed
      }
    }
  }

  static Future<String> createBranchLink({
    required String path,
    Map<String, dynamic>? params,
    String? title,
    String? description,
  }) async {
    BranchUniversalObject buo = BranchUniversalObject(
      canonicalIdentifier: path,
      title: title ?? 'Parsa App',
      description: description ?? 'Check out this content on Parsa',
      publiclyIndex: true,
      locallyIndex: true,
      contentMetadata: BranchContentMetaData()..customMetadata = params,
    );

    BranchLinkProperties lp = BranchLinkProperties(
      channel: 'app',
      feature: 'sharing',
      stage: 'new share',
      campaign: 'content share',
      tags: ['parsa-ai'],
    )
      ..addControlParam('\$deeplink_path', path)
      ..addControlParam('\$desktop_url', 'https://app.parsa-ai.com.br/$path')
      ..addControlParam('\$android_url',
          'https://play.google.com/store/apps/details?id=com.parsa.app')
      ..addControlParam('\$ios_url', 'https://apps.apple.com/app/idYOUR_APP_ID')
      ..addControlParam('\$fallback_url', 'https://app.parsa-ai.com.br');

    BranchResponse response = await FlutterBranchSdk.getShortUrl(
      buo: buo,
      linkProperties: lp,
    );

    if (response.success) {
      return response.result;
    } else {
      throw Exception('Failed to create Branch link: ${response.errorMessage}');
    }
  }
}
