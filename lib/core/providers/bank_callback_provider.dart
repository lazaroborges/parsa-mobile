import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class BankCallbackProvider extends ChangeNotifier {
  bool _bankCallbackReceived = false;

  static BankCallbackProvider? _instance;
  static BankCallbackProvider get instance {
    _instance ??= BankCallbackProvider();
    return _instance!;
  }

  bool get bankCallbackReceived => _bankCallbackReceived;

  void setBankCallbackReceived(bool value) {
    if (_bankCallbackReceived != value) {
      if (kDebugMode) {
        print('🏦 BankCallbackProvider: setting flag to $value');
      }
      _bankCallbackReceived = value;
      notifyListeners();
    }
  }

  void reset() {
    if (_bankCallbackReceived) {
      if (kDebugMode) {
        print('🏦 BankCallbackProvider: resetting flag');
      }
      _bankCallbackReceived = false;
      notifyListeners();
    }
  }
}
