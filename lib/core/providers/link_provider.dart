import 'package:flutter/material.dart';

/// Manages the state of a pending deep link received before authentication or app readiness.
class LinkProvider extends ChangeNotifier {
  String? _pendingDeepLink;

  // Singleton pattern
  static LinkProvider? _instance;
  static LinkProvider get instance {
    _instance ??= LinkProvider._(); // Initialize if null
    return _instance!;
  }

  // Private constructor for singleton
  LinkProvider._();

  /// The pending deep link URL or path, if any.
  String? get pendingDeepLink => _pendingDeepLink;

  /// Stores a deep link to be processed later.
  ///
  /// [link]: The deep link URL or path string.
  void setPendingDeepLink(String link) {
    if (_pendingDeepLink != link) {
      debugPrint('Setting pending deep link: $link');
      _pendingDeepLink = link;
      notifyListeners();
    }
  }

  /// Clears the stored pending deep link.
  void clearPendingDeepLink() {
    if (_pendingDeepLink != null) {
      debugPrint('Clearing pending deep link: $_pendingDeepLink');
      _pendingDeepLink = null;
      notifyListeners();
    }
  }
}
