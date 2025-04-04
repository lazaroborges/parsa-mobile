import 'package:flutter/material.dart';

/// Manages the state of pending deep link information received before authentication or app readiness.
class LinkProvider extends ChangeNotifier {
  Uri? _pendingUri;

  // Singleton pattern
  static LinkProvider? _instance;
  static LinkProvider get instance {
    _instance ??= LinkProvider._(); // Initialize if null
    return _instance!;
  }

  LinkProvider._();

  /// Pending standard deep link URI, if any.
  Uri? get pendingUri => _pendingUri;

  /// Stores a deep link URI to be processed later.
  /// [uri]: The deep link URI.
  void setPendingUri(Uri uri) {
    if (_pendingUri != uri) {
      _pendingUri = uri;
      notifyListeners();
    }
  }

  /// Clears stored pending URI.
  void clearPendingUri() {
    if (_pendingUri != null) {
      debugPrint('Clearing pending URI: $_pendingUri');
      _pendingUri = null;
      notifyListeners();
    }
  }
}
