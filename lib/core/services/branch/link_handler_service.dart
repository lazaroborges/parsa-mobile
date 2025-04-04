import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:parsa/core/database/services/budget/budget_service.dart';
import 'package:parsa/core/database/services/account/account_service.dart';
import 'package:parsa/core/database/services/transaction/transaction_service.dart';
import 'package:parsa/core/presentation/widgets/transaction_filter/transaction_filters.dart';
import 'package:parsa/core/routes/go_router_config.dart';
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
          print('Branch session data received: $data');
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
        print('Processing pending URI: $pendingUri');

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
        print('Clearing pending URI');
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

      // Check if this is a clicked branch link
      if (data.containsKey('+clicked_branch_link') &&
          data['+clicked_branch_link'] == true) {
        // Extract path and link data
        String? path;

        // Extract deeplink path if available
        if (data.containsKey('\$deeplink_path')) {
          path = data['\$deeplink_path'] as String?;
        }
        // If no deeplink_path, try to get it from non_branch_link or referring_link
        else if (data.containsKey('+non_branch_link')) {
          final String url = data['+non_branch_link'] as String;
          path = _extractPathFromUrl(url);
        } else if (data.containsKey('~referring_link')) {
          final String url = data['~referring_link'] as String;
          path = _extractPathFromUrl(url);
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
        } else {
          print('No custom_data found in Branch data');
        }

        // If we have a path, route based on it
        if (path != null && path.isNotEmpty) {
          print('Will route based on path: $path');
          _routeBasedOnPath(path, customParams);
        } else {
          print('No path found in Branch data: $data');
          NavigationDelegate.instance.navigateTo('/');
        }
      } else {
        print('Not a clicked branch link or missing +clicked_branch_link flag');
      }
    } catch (e) {
      print('Error processing Branch data: $e');
    } finally {
      _isProcessingDeepLink = false;
    }
  }

  /// Extract path from a URL string
  String _extractPathFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      String path = uri.path;

      // If path is empty, try to extract from the URL itself
      if (path.isEmpty) {
        // Handle cases like "app.link/accounts"
        final segments = url.split('/');
        if (segments.length > 1) {
          return segments.last;
        }
      }

      return path.startsWith('/') ? path.substring(1) : path;
    } catch (e) {
      print('Error extracting path from URL: $e');
      return '';
    }
  }

  /// Route to the appropriate page based on the path and parameters
  void _routeBasedOnPath(String path, Map<dynamic, String> params) {
    print(
        'DEBUG: Starting _routeBasedOnPath with path: "$path", Params: $params');

    // Check authentication before navigating
    final auth0Provider = Auth0Provider.instance;
    if (auth0Provider.credentials == null) {
      print('DEBUG: User not authenticated, cannot navigate yet');
      return;
    }
    print('DEBUG: User is authenticated, proceeding with navigation');

    // Handle path that might have leading slash
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    print('DEBUG: Clean path: "$cleanPath"');

    // Split path into segments
    final segments = cleanPath.split('/');
    print('DEBUG: Path segments: $segments');

    if (segments.isEmpty) {
      print('DEBUG: No segments found, navigating to home');
      try {
        print('DEBUG: About to navigate to home page');
        NavigationDelegate.instance.navigateTo('/');
        print('DEBUG: Navigation to home completed');
      } catch (e) {
        print('ERROR: Failed to navigate to home: $e');
        print('ERROR: Stack trace: ${StackTrace.current}');
      }
      return;
    }

    // Get the main section and the ID if available
    final section = segments[0].toLowerCase();
    final id = segments.length > 1 ? segments[1] : params['id'];
    print('DEBUG: Main section: "$section", ID: $id');

    switch (section) {
      case 'budgets':
        if (id != null) {
          print('DEBUG: Navigating to specific budget: $id');
          NavigationDelegate.instance.navigateToBudget(id);
        } else {
          print('DEBUG: Navigating to budgets list');
          NavigationDelegate.instance.navigateTo('/budgets');
        }
        break;

      case 'transactions':
        if (id != null) {
          print('DEBUG: Navigating to specific transaction: $id');
          NavigationDelegate.instance.navigateToTransaction(id);
        } else {
          print('DEBUG: Navigating to transactions list');
          NavigationDelegate.instance.navigateTo('/transactions');
        }
        break;

      case 'accounts':
        if (id != null) {
          print('DEBUG: Navigating to specific account: $id');
          try {
            NavigationDelegate.instance.navigateToAccount(id);
          } catch (e) {
            print('ERROR: Failed to navigate to account $id: $e');
            print('ERROR: Stack trace: ${StackTrace.current}');
          }
        } else {
          print('DEBUG: Navigating to accounts list');
          try {
            print(
                'DEBUG: About to call NavigationDelegate.navigateTo("/accounts")');
            NavigationDelegate.instance.navigateTo('/accounts');
            print('DEBUG: Navigation call completed');
          } catch (e) {
            print('ERROR: Failed to navigate to accounts list: $e');
            print('ERROR: Stack trace: ${StackTrace.current}');
          }
        }
        break;

      case 'stats':
        print('DEBUG: Handling stats section');
        final subPath =
            segments.length > 1 ? segments.sublist(1).join('/') : '';
        print('DEBUG: Stats subpath: "$subPath"');

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
        print('DEBUG: Navigating to subscription');
        NavigationDelegate.instance.navigateTo('/subscription');
        break;

      case 'settings':
        print('DEBUG: Handling settings section');
        if (segments.length > 1) {
          final settingsSection = segments[1].toLowerCase();
          print('DEBUG: Settings subsection: $settingsSection');

          switch (settingsSection) {
            case 'preferences':
              print('DEBUG: Navigating to preferences settings');
              NavigationDelegate.instance.navigateTo('/settings/preferences');
              break;
            case 'about':
              print('DEBUG: Navigating to about settings');
              NavigationDelegate.instance.navigateTo('/settings/about');
              break;
            case 'export':
              print('DEBUG: Navigating to export settings');
              NavigationDelegate.instance.navigateTo('/settings/export');
              break;
            default:
              print(
                  'DEBUG: Unknown settings subsection, navigating to settings home');
              NavigationDelegate.instance.navigateTo('/settings');
              break;
          }
        } else {
          print('DEBUG: Navigating to settings home');
          NavigationDelegate.instance.navigateTo('/settings');
        }
        break;

      default:
        print('Unhandled deep link path: $path');
        NavigationDelegate.instance.navigateTo('/');
        break;
    }
  }

  /// Handle an external deep link
  Future<void> handleDeepLink(String url) async {
    try {
      print('DEBUG: handleDeepLink called with URL: $url');

      // Parse URI to check if it's valid
      Uri uri;
      try {
        uri = Uri.parse(url);
        print('DEBUG: Successfully parsed URI: $uri');
      } catch (e) {
        print('DEBUG: Error parsing URI: $e');
        return;
      }

      // Extract path for logging
      final path =
          uri.path.isNotEmpty ? uri.path : uri.toString().split('://').last;
      print('DEBUG: Path extracted from URL: $path');

      // Let Branch SDK handle it directly - it will trigger our listener
      print('DEBUG: Forwarding to FlutterBranchSdk.handleDeepLink()');
      FlutterBranchSdk.handleDeepLink(url);
    } catch (e) {
      print('DEBUG: Error in handleDeepLink: $e');
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _branchSubscription?.cancel();
    _branchSubscription = null;
    print('LinkHandlerService disposed.');
  }
}
