import 'package:flutter/material.dart';

class UserDataProvider extends ChangeNotifier {
  Map<String, dynamic>? _userData;
  
  // Add singleton pattern
  static UserDataProvider? _instance;
  static UserDataProvider get instance {
    _instance ??= UserDataProvider();
    return _instance!;
  }

  Map<String, dynamic>? get userData => _userData;

  void setUserData(Map<String, dynamic>? data) {
    _userData = data;
    notifyListeners();
  }

  void updateUserData(Map<String, dynamic> updates) {
    if (_userData == null) {
      _userData = {};
    }
    
    // Update the userData with the new values
    _userData!.addAll(updates);
    
    // Notify listeners about the change
    notifyListeners();
  }
}