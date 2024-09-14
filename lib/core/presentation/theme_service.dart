import 'package:flutter/material.dart';

class ThemeService extends ChangeNotifier {
  ThemeData _themeData;

  ThemeService(this._themeData);

  ThemeData get themeData => _themeData;

  void updateTheme(ThemeData newTheme) {
    _themeData = newTheme;
    notifyListeners();
  }
}
