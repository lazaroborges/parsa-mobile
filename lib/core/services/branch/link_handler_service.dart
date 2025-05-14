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
import 'package:parsa/app/accounts/bank_callback_dialog.dart';
import 'package:flutter/material.dart';
import 'package:parsa/core/utils/check_items_availability.dart';

/// A service to handle deep links from Branch SDK and direct app links
class LinkHandlerService {
  static final LinkHandlerService instance = LinkHandlerService._();
  LinkHandlerService._();

  StreamSubscription<Map>? _branchSubscription;
  bool _isProcessingDeepLink = false;

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
  Future<void> processPendingDeepLinks({Function? onComplete}) async {
    if (_isProcessingDeepLink) {
      return;
    }

    _isProcessingDeepLink = true;

    try {
      final linkProvider = LinkProvider.instance;
      final pendingUri = linkProvider.pendingUri;

      if (pendingUri != null) {
        final uriStr = pendingUri.toString();

        // --- Branch Link ---
        if (uriStr.contains('app.link')) {
          debugPrint(
              '[LinkHandlerService] (processPendingDeepLinks) Handling Branch link: $pendingUri (will rely on Branch SDK listener, not calling handleDeepLink)');
          // Do not call FlutterBranchSdk.handleDeepLink; rely on the Branch SDK listener.
        }

        // --- Callback Link ---
        else if (pendingUri.scheme == 'com.parsa.app' &&
            pendingUri.host == 'callback') {
          debugPrint(
              '[LinkHandlerService] (processPendingDeepLinks) Handling callback link: $pendingUri');
          await _handleCallbackLink(pendingUri);
        }
        // --- Unknown Link ---
        else {
          print('Unhandled deep link: $uriStr');
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
        debugPrint(
            '[LinkHandlerService] Clearing pending URI: ${linkProvider.pendingUri}');
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

      if (data.containsKey('+clicked_branch_link') &&
          data['+clicked_branch_link'] == true) {
        String? path;

        // Extract deeplink path if available
        if (data.containsKey('\$deeplink_path')) {
          path = data['\$deeplink_path'] as String?;
        }
        if (data.containsKey('\$deeplink_path')) {
          debugPrint(
              '[LinkHandlerService] Branch data contains deeplink_path: ${data['\$deeplink_path']}');
        }

        // If we have a path, route based on it
        if (path != null && path.isNotEmpty) {
          debugPrint(
              '[LinkHandlerService] Routing based on deeplink_path: $path');
          _routeBasedOnPath(path, {});
        } else {
          debugPrint(
              '[LinkHandlerService] No deeplink_path found, routing to dashboard');
          NavigationDelegate.instance.navigateToAppRoute('dashboard');
        }
      }
    } catch (e) {
      print('Error processing Branch data: $e');
    } finally {
      _isProcessingDeepLink = false;
    }
  }

  /// Handle callback link logic (shared by pending and live handling)
  Future<void> _handleCallbackLink(Uri pendingUri) async {
    debugPrint(
        '[LinkHandlerService] Entered _handleCallbackLink with uri: $pendingUri');
    final context = navigatorKey.currentContext;
    if (context != null) {
      try {
        debugPrint(
            '[LinkHandlerService] Checking account availability for callback link...');
        final errorMessage = await checkItemAvailability(context);
        final canConnectMoreAccounts = errorMessage == null;
        debugPrint(
            '[LinkHandlerService] Account availability check result: canConnectMoreAccounts=$canConnectMoreAccounts, errorMessage=$errorMessage');
        if (canConnectMoreAccounts) {
          debugPrint('[LinkHandlerService] Showing BankCallbackDialog...');
          await Future.microtask(() async {
            await BankCallbackDialog.showAndHandle(context);
          });
        } else {
          debugPrint(
              '[LinkHandlerService] Cannot connect more accounts, showing error.');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(errorMessage ?? 'Erro ao verificar disponibilidade')),
          );
        }
      } catch (e) {
        print('Error checking account availability: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao verificar disponibilidade')),
        );
      }
    } else {
      debugPrint(
          '[LinkHandlerService] No context available for BankCallbackDialog');
      print('No context available for BankCallbackDialog');
    }
  }

  /// Route to the appropriate page based on the path and parameters
  void _routeBasedOnPath(String path, Map<dynamic, String> params) {
    debugPrint(
        '[LinkHandlerService] Entered _routeBasedOnPath with path: $path, params: $params');
    final auth0Provider = Auth0Provider.instance;
    if (auth0Provider.credentials == null) {
      debugPrint('[LinkHandlerService] No credentials, aborting navigation.');
      return;
    }

    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    final segments = cleanPath.split('/');

    if (segments.isEmpty) {
      debugPrint(
          '[LinkHandlerService] No segments found, routing to dashboard.');
      NavigationDelegate.instance.navigateToAppRoute('dashboard');
      return;
    }

    final section = segments[0].toLowerCase();
    debugPrint('[LinkHandlerService] Routing section: $section');
    final id = segments.length > 1 ? segments[1] : params['id'];
    final context = navigatorKey.currentContext;

    switch (section) {
      case 'dashboard':
        debugPrint('[LinkHandlerService] Routing to dashboard');
        NavigationDelegate.instance.navigateToAppRoute('dashboard');
        break;
      case 'budgets':
        debugPrint('[LinkHandlerService] Routing to budgets, id: $id');
        if (id != null) {
          BudgetService.instance.getBudgetById(id).first.then((data) {
            NavigationDelegate.instance.navigateToAppRoute(
              'budgets/id',
              id: id,
              data: data,
            );
          });
        } else {
          NavigationDelegate.instance.navigateToAppRoute('budgets');
        }
        break;
      case 'transactions':
        debugPrint('[LinkHandlerService] Routing to transactions, id: $id');
        if (id != null) {
          TransactionService.instance.getTransactionById(id).first.then((data) {
            NavigationDelegate.instance.navigateToAppRoute(
              'transactions/id',
              id: id,
              data: data,
            );
          });
        } else {
          NavigationDelegate.instance.navigateToAppRoute('transactions');
        }
        break;
      case 'accounts':
        debugPrint('[LinkHandlerService] Routing to accounts, id: $id');
        if (id != null) {
          AccountService.instance.getAccountById(id).first.then((data) {
            NavigationDelegate.instance.navigateToAppRoute(
              'accounts/id',
              id: id,
              data: data,
            );
          });
        } else {
          NavigationDelegate.instance.navigateToAppRoute('accounts');
        }
        break;
      case 'tags':
        debugPrint('[LinkHandlerService] Routing to tags, id: $id');
        if (id != null && context != null) {
          fetchAndFindTagById(context, id).then((data) {
            NavigationDelegate.instance.navigateToAppRoute(
              'tags/id',
              id: id,
              data: data,
            );
          });
        } else {
          NavigationDelegate.instance.navigateToAppRoute('tags');
        }
        break;
      case 'stats':
        debugPrint('[LinkHandlerService] Routing to stats');
        if (segments.length > 1) {
          final subPath = segments.sublist(1).join('/');
          NavigationDelegate.instance.navigateToAppRoute('stats/$subPath');
        } else {
          NavigationDelegate.instance.navigateToAppRoute('stats');
        }
        break;
      case 'subscription':
        debugPrint('[LinkHandlerService] Routing to subscription');
        NavigationDelegate.instance.navigateToAppRoute('subscription');
        break;
      case 'settings':
        debugPrint('[LinkHandlerService] Routing to settings');
        NavigationDelegate.instance.navigateToAppRoute('settings');
        break;
      default:
        debugPrint('[LinkHandlerService] Unhandled deep link path: $path');
        print('Unhandled deep link path: $path');
        NavigationDelegate.instance.navigateToAppRoute('dashboard');
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
