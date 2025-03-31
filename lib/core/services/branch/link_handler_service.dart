import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:parsa/core/routes/go_router_config.dart';

class LinkHandlerService {
  static final LinkHandlerService instance = LinkHandlerService._();
  LinkHandlerService._();

  StreamSubscription<Map>? _branchSubscription;
  final Map<String, String> _branchParams = {};

  Future<void> initialize() async {
    try {
      // Set up session listener for Branch deep links
      _branchSubscription = FlutterBranchSdk.listSession().listen(
        (data) => _handleDeepLinkData(data),
        onError: (error) => debugPrint('Branch session listener error: $error'),
      );

      // Check initial referring data
      await _checkInitialReferringData();
    } catch (e) {
      debugPrint('Error initializing link handler: $e');
    }
  }

  Future<void> _checkInitialReferringData() async {
    try {
      final initialParams = await FlutterBranchSdk.getFirstReferringParams();
      if (initialParams.isNotEmpty) {
        _handleDeepLinkData(initialParams);
      }

      final latestParams = await FlutterBranchSdk.getLatestReferringParams();
      if (latestParams.isNotEmpty) {
        debugPrint('Latest referring data: $latestParams');
      }
    } catch (e) {
      debugPrint('Error checking initial referring data: $e');
    }
  }

  void _handleDeepLinkData(Map<dynamic, dynamic> data) {
    debugPrint('Deep link data received: $data');

    try {
      if (data.containsKey('+clicked_branch_link') &&
          data['+clicked_branch_link'] == true) {
        final String? linkPath = data['+deeplink_path'] as String?;
        final bool isFirstSession = data['+is_first_session'] ?? false;

        debugPrint('Is first session: $isFirstSession');
        debugPrint('Deep link path: $linkPath');

        _extractAndSaveCustomData(data);

        if (linkPath != null) {
          _navigateBasedOnPath(linkPath);
        }
      }
    } catch (e) {
      debugPrint('Error handling deep link data: $e');
    }
  }

  void _extractAndSaveCustomData(Map<dynamic, dynamic> data) {
    try {
      if (data.containsKey('custom_data') && data['custom_data'] is Map) {
        final customData = data['custom_data'] as Map;
        _branchParams.clear();

        for (final entry in customData.entries) {
          _branchParams[entry.key.toString()] = entry.value.toString();
        }
      }
    } catch (e) {
      debugPrint('Error extracting custom data: $e');
    }
  }

  void _navigateBasedOnPath(String path) {
    try {
      switch (path) {
        case 'subscription':
          goRouter.go('/subscription');
          break;
        case 'accounts':
          final accountId = _branchParams['id'];
          goRouter.go(accountId != null ? '/accounts/$accountId' : '/accounts');
          break;
        case 'transactions':
          final transactionId = _branchParams['id'];
          goRouter.go(transactionId != null
              ? '/transactions/$transactionId'
              : '/transactions');
          break;
        case 'budgets':
          final budgetId = _branchParams['id'];
          goRouter.go(budgetId != null ? '/budgets/$budgetId' : '/budgets');
          break;
        default:
          goRouter.go('/');
          break;
      }
    } catch (e) {
      debugPrint('Error navigating to path: $e');
      goRouter.go('/');
    }
  }

  Future<void> handleDeepLink(String url) async {
    try {
      FlutterBranchSdk.handleDeepLink(url);
      debugPrint('Handled deep link: $url');
    } catch (e) {
      debugPrint('Error handling deep link: $e');
    }
  }

  Future<bool> listOnSearch(BranchUniversalObject buo) async {
    try {
      return await FlutterBranchSdk.listOnSearch(buo: buo);
    } catch (e) {
      debugPrint('Error listing on search: $e');
      return false;
    }
  }

  Future<bool> removeFromSearch(BranchUniversalObject buo) async {
    try {
      return await FlutterBranchSdk.removeFromSearch(buo: buo);
    } catch (e) {
      debugPrint('Error removing from search: $e');
      return false;
    }
  }

  void registerView(BranchUniversalObject buo) {
    try {
      FlutterBranchSdk.registerView(buo: buo);
    } catch (e) {
      debugPrint('Error registering view: $e');
    }
  }

  void trackContent({
    required List<BranchUniversalObject> buo,
    required BranchEvent branchEvent,
  }) {
    try {
      FlutterBranchSdk.trackContent(buo: buo, branchEvent: branchEvent);
    } catch (e) {
      debugPrint('Error tracking content: $e');
    }
  }

  void trackContentWithoutBuo(BranchEvent branchEvent) {
    try {
      FlutterBranchSdk.trackContentWithoutBuo(branchEvent: branchEvent);
    } catch (e) {
      debugPrint('Error tracking content without BUO: $e');
    }
  }

  Future<void> dispose() async {
    await _branchSubscription?.cancel();
    _branchSubscription = null;
    _branchParams.clear();
  }
}
