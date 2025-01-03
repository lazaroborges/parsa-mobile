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
}