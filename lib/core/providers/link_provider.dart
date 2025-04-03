import 'package:flutter/material.dart';

/// Manages the state of pending deep link information received before authentication or app readiness.
class LinkProvider extends ChangeNotifier {
  Map<dynamic, dynamic>? _pendingBranchData;
  Uri? _pendingUri;

  // Singleton pattern
  static LinkProvider? _instance;
  static LinkProvider get instance {
    _instance ??= LinkProvider._(); // Initialize if null
    return _instance!;
  }

  LinkProvider._();

  /// Pending Branch.io link data map, if any.
  Map<dynamic, dynamic>? get pendingBranchData => _pendingBranchData;

  /// Pending standard deep link URI, if any.
  Uri? get pendingUri => _pendingUri;

  /// Stores Branch.io link data to be processed later.
  ///
  /// Automatically clears any pending URI.
  /// [data]: The Branch link data map.
  void setPendingBranchData(Map<dynamic, dynamic> data) {
    // Check if data is actually different to avoid unnecessary notifications
    // Note: Deep map comparison can be complex; this is a basic check.
    if (_pendingBranchData.toString() != data.toString()) {
      debugPrint('Setting pending branch data: $data');
      _pendingBranchData = data;
      if (_pendingUri != null) {
        _pendingUri = null; // Ensure only one type is set
      }
      notifyListeners();
    } else if (_pendingUri != null) {
      // Data is the same, but we need to clear the other type
      _pendingUri = null;
      notifyListeners();
    }
  }

  /// Stores a standard deep link URI to be processed later.
  ///
  /// Automatically clears any pending Branch data.
  /// [uri]: The deep link URI.
  void setPendingUri(Uri uri) {
    if (_pendingUri != uri) {
      debugPrint('Setting pending URI: $uri');
      _pendingUri = uri;
      if (_pendingBranchData != null) {
        _pendingBranchData = null; // Ensure only one type is set
      }
      notifyListeners();
    } else if (_pendingBranchData != null) {
      // URI is the same, but we need to clear the other type
      _pendingBranchData = null;
      notifyListeners();
    }
  }

  /// Clears all stored pending link information (Branch data and URI).
  void clearPendingLinks() {
    if (_pendingBranchData != null || _pendingUri != null) {
      debugPrint(
          'Clearing pending links. Branch Data: $_pendingBranchData, URI: $_pendingUri');
      _pendingBranchData = null;
      _pendingUri = null;
      notifyListeners();
    }
  }
}
