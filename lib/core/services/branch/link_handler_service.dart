import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:parsa/core/routes/navigation_delegate.dart';
import 'package:parsa/core/services/auth/auth0_class.dart';
import 'package:parsa/core/providers/link_provider.dart';

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

      if (data.containsKey('+clicked_branch_link') &&
          data['+clicked_branch_link'] == true) {
        String? path;

        // Extract deeplink path if available
        if (data.containsKey('\$deeplink_path')) {
          path = data['\$deeplink_path'] as String?;
        }

        // Extract custom data if available
        Map<String, String> customParams = {};
        if (data.containsKey('custom_data')) {
          final customData = data['custom_data'];
          if (customData is Map) {
            customData.forEach((key, value) {
              customParams[key.toString()] = value.toString();
            });
          }
        }

        // If we have a path, route based on it
        if (path != null && path.isNotEmpty) {
          _routeBasedOnPath(path, customParams);
        } else {
          NavigationDelegate.instance.navigateTo('/');
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

    // Handle path that might have leading slash
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;

    // Split path into segments
    final segments = cleanPath.split('/');

    if (segments.isEmpty) {
      try {
        NavigationDelegate.instance.navigateTo('/');
      } catch (e) {
        print('Error navigating to home: $e');
      }
      return;
    }

    // Get the main section and the ID if available
    final section = segments[0].toLowerCase();
    final id = segments.length > 1 ? segments[1] : params['id'];

    switch (section) {
      case 'budgets':
        if (id != null) {
          NavigationDelegate.instance.navigateToBudget(id);
        } else {
          NavigationDelegate.instance.navigateTo('/budgets');
        }
        break;

      case 'transactions':
        if (id != null) {
          NavigationDelegate.instance.navigateToTransaction(transactionId: id);
        } else {
          // Convert params to String,String map for filters
          final stringParams = <String, String>{};
          params.forEach((key, value) {
            if (key is String) {
              stringParams[key] = value;
            }
          });

          if (stringParams.isNotEmpty) {
            NavigationDelegate.instance
                .navigateToTransaction(params: stringParams);
          } else {
            NavigationDelegate.instance.navigateTo('/transactions');
          }
        }
        break;

      case 'accounts':
        if (id != null) {
          try {
            NavigationDelegate.instance.navigateToAccount(id);
          } catch (e) {
            print('Error navigating to account $id: $e');
          }
        } else {
          try {
            NavigationDelegate.instance.navigateTo('/accounts');
          } catch (e) {
            print('Error navigating to accounts list: $e');
          }
        }
        break;

      case 'stats':
        final subPath =
            segments.length > 1 ? segments.sublist(1).join('/') : '';

        // Convert params to String,String map for _navigateToStats
        final stringParams = <String, String>{};
        params.forEach((key, value) {
          if (key is String) {
            stringParams[key] = value;
          }
        });

        NavigationDelegate.instance.navigateToStats(subPath, stringParams);
        break;

      case 'subscription':
        NavigationDelegate.instance.navigateTo('/subscription');
        break;

      case 'settings':
        if (segments.length > 1) {
          final settingsSection = segments[1].toLowerCase();

          switch (settingsSection) {
            case 'preferences':
              NavigationDelegate.instance.navigateTo('/settings/preferences');
              break;
            case 'about':
              NavigationDelegate.instance.navigateTo('/settings/about');
              break;
            case 'export':
              NavigationDelegate.instance.navigateTo('/settings/export');
              break;
            default:
              NavigationDelegate.instance.navigateTo('/settings');
              break;
          }
        } else {
          NavigationDelegate.instance.navigateTo('/settings');
        }
        break;

      default:
        print('Unhandled deep link path: $path');
        NavigationDelegate.instance.navigateTo('/');
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
