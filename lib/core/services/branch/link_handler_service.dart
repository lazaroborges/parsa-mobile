import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:parsa/core/routes/navigation_delegate.dart';
import 'package:parsa/core/services/auth/auth0_class.dart';
import 'package:parsa/core/providers/link_provider.dart';
import 'package:parsa/core/routes/pending_navigation.dart';
import 'package:parsa/core/database/services/account/account_service.dart';
import 'package:parsa/core/database/services/budget/budget_service.dart';
import 'package:parsa/core/database/services/transaction/transaction_service.dart';
import 'package:parsa/main.dart';
import 'package:parsa/core/providers/bank_callback_provider.dart';

/// A service to handle deep links from Branch SDK and direct app links
class LinkHandlerService {
  static final LinkHandlerService instance = LinkHandlerService._();
  LinkHandlerService._();

  StreamSubscription<Map>? _branchSubscription;
  bool _isProcessingDeepLink = false;
  PendingNavigation? pendingNavigation;

  /// Initialize the link handler service and set up Branch SDK listeners
  Future<void> initialize() async {
    try {
      // Set up the Branch SDK listener for deep links
      _branchSubscription = FlutterBranchSdk.listSession().listen(
        (data) {
          // Process branch data if authenticated
          if (Auth0Provider.instance.credentials != null) {
            _processBranchData(data);
          }
        },
        onError: (error) {
          PlatformException platformException = error as PlatformException;
          print(
              'Branch SDK stream error: ${platformException.code} - ${platformException.message}');
        },
      );
    } catch (e) {
      print('Error initializing LinkHandlerService: $e');
    }
  }

  /// Process any stored URI from LinkProvider
  void processPendingDeepLinks({Function? onComplete}) {
    if (_isProcessingDeepLink) {
      return;
    }

    _isProcessingDeepLink = true;

    try {
      final linkProvider = LinkProvider.instance;
      final pendingUri = linkProvider.pendingUri;

      if (pendingUri != null) {
        // Extract path and params from URI
        final path = pendingUri.path.isNotEmpty
            ? pendingUri.path
            : pendingUri.toString().split('://').last;

        // Handle URI directly for standard deep links
        _routeBasedOnPath(path, pendingUri.queryParameters);

        // For Branch links, also let Branch SDK handle them
        if (pendingUri.toString().contains('app.link') ||
            pendingUri.scheme == 'com.parsa.app') {
          FlutterBranchSdk.handleDeepLink(pendingUri.toString());
        }

        // Call onComplete callback if provided
        if (onComplete != null) {
          onComplete();
        }
      }
    } catch (e) {
      print('Error processing pending deep links: $e');
    } finally {
      _isProcessingDeepLink = false;
    }
  }

  /// Clear any pending URI from the LinkProvider
  void clearPendingUri() {
    try {
      final linkProvider = LinkProvider.instance;
      if (linkProvider.pendingUri != null) {
        linkProvider.clearPendingUri();
      }
    } catch (e) {
      print('Error clearing pending URI: $e');
    }
  }

  /// Process Branch data received from the listener
  void _processBranchData(Map<dynamic, dynamic> data) {
    if (_isProcessingDeepLink || data.isEmpty) {
      return;
    }

    try {
      _isProcessingDeepLink = true;
      if (kDebugMode) {
        print('Processing Branch data: $data');
      }

      // Extract custom data if available and set the bank callback flag if present
      Map<String, String> customParams = {};
      if (data.containsKey('custom_data')) {
        final customData = data['custom_data'];
        if (customData is Map) {
          customData.forEach((key, value) {
            customParams[key.toString()] = value.toString();
          });
        }
      }
      // Set the bank callback flag if the param is present and true
      if (customParams['bank_callback'] == 'true') {
        BankCallbackProvider.instance.setBankCallbackReceived(true);
      }

      if (data.containsKey('+clicked_branch_link') &&
          data['+clicked_branch_link'] == true) {
        String? path;

        // Extract deeplink path if available
        if (data.containsKey('\$deeplink_path')) {
          path = data['\$deeplink_path'] as String?;
        }

        // If we have a path, route based on it
        if (path != null && path.isNotEmpty) {
          _routeBasedOnPath(path, customParams);
        } else {
          NavigationDelegate.instance.navigateToAppRoute('dashboard');
        }
      }
    } catch (e) {
      print('Error processing Branch data: $e');
    } finally {
      _isProcessingDeepLink = false;
    }
  }

  /// Route to the appropriate page based on the path and parameters
  void _routeBasedOnPath(String path, Map<dynamic, String> params) {
    final auth0Provider = Auth0Provider.instance;
    if (auth0Provider.credentials == null) {
      return;
    }

    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    final segments = cleanPath.split('/');

    if (segments.isEmpty) {
      pendingNavigation = PendingNavigation(route: 'dashboard');
      return;
    }

    final section = segments[0].toLowerCase();
    final id = segments.length > 1 ? segments[1] : params['id'];
    Future<dynamic>? dataFuture;
    final context = navigatorKey.currentContext;

    switch (section) {
      case 'dashboard':
        pendingNavigation = PendingNavigation(route: 'dashboard');
        break;
      case 'budgets':
        if (id != null) {
          dataFuture = BudgetService.instance.getBudgetById(id).first;
          pendingNavigation = PendingNavigation(
              route: 'budgets/id', id: id, dataFuture: dataFuture);
        } else {
          pendingNavigation = PendingNavigation(route: 'budgets');
        }
        break;
      case 'transactions':
        if (id != null) {
          dataFuture = TransactionService.instance.getTransactionById(id).first;
          pendingNavigation = PendingNavigation(
              route: 'transactions/id', id: id, dataFuture: dataFuture);
        } else {
          pendingNavigation = PendingNavigation(route: 'transactions');
        }
        break;
      case 'accounts':
        if (id != null) {
          dataFuture = AccountService.instance.getAccountById(id).first;
          pendingNavigation = PendingNavigation(
              route: 'accounts/id', id: id, dataFuture: dataFuture);
        } else {
          pendingNavigation = PendingNavigation(route: 'accounts');
        }
        break;
      case 'tags':
        if (id != null && context != null) {
          dataFuture = fetchAndFindTagById(context, id);
          pendingNavigation = PendingNavigation(
              route: 'tags/id', id: id, dataFuture: dataFuture);
        } else {
          pendingNavigation = PendingNavigation(route: 'tags');
        }
        break;
      case 'stats':
        if (segments.length > 1) {
          final subPath = segments.sublist(1).join('/');
          pendingNavigation = PendingNavigation(route: 'stats/$subPath');
        } else {
          pendingNavigation = PendingNavigation(route: 'stats');
        }
        break;
      case 'subscription':
        pendingNavigation = PendingNavigation(route: 'subscription');
        break;
      case 'settings':
        pendingNavigation = PendingNavigation(route: 'settings');
        break;
      default:
        print('Unhandled deep link path: $path');
        pendingNavigation = PendingNavigation(route: 'dashboard');
        break;
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _branchSubscription?.cancel();
    _branchSubscription = null;
    print('LinkHandlerService disposed.');
  }
}
