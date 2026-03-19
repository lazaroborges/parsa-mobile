import 'package:flutter/material.dart';
import 'package:parsa/core/presentation/theme.dart';
import 'package:parsa/core/utils/shared_preferences_async.dart';
import 'package:rxdart/rxdart.dart';

class ForecastModeService {
  static const String keyForecastMode = 'currentForecastMode';

  ForecastModeService._();
  static final ForecastModeService instance = ForecastModeService._();

  // --- Color schemes ---

  static final ColorScheme _forecastColorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF0D9488), // Teal — harmonizes with the blue theme
    brightness: Brightness.light,
  );

  // Stores the user's real color scheme and accent color for restoring
  ColorScheme _realColorScheme = ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.light,
  );
  String _realAccentColor = 'blue';

  // --- Streams ---

  final _forecastModeController = BehaviorSubject<bool>.seeded(false);
  Stream<bool> get forecastModeStream => _forecastModeController.stream;
  bool get isInForecastMode => _forecastModeController.value;

  late final _themeController = BehaviorSubject<ThemeData>.seeded(
    getThemeData(
      lightColorScheme: _realColorScheme,
      accentColor: _realAccentColor,
    ),
  );
  Stream<ThemeData> get themeStream => _themeController.stream;
  ThemeData get currentTheme => _themeController.value;

  void dispose() {
    _forecastModeController.close();
    _themeController.close();
  }

  /// Configure the real theme that should be restored when exiting forecast mode.
  /// Call this from MaterialAppContainer when the user's settings are known.
  void setRealTheme(ColorScheme colorScheme, String accentColor) {
    _realColorScheme = colorScheme;
    _realAccentColor = accentColor;

    // If not in forecast mode, update the theme immediately
    if (!isInForecastMode) {
      _themeController.add(
        getThemeData(
          lightColorScheme: _realColorScheme,
          accentColor: _realAccentColor,
        ),
      );
    }
  }

  /// Initialize — always start in regular (non-forecast) mode
  Future<void> initialize() async {
    setForecastMode(false);
  }

  /// Set the forecast mode and emit theme + mode changes
  void setForecastMode(bool value) {
    _forecastModeController.add(value);
    SharedPreferencesAsync.instance.setBool(keyForecastMode, value);

    final colorScheme = value ? _forecastColorScheme : _realColorScheme;
    final accentColor = value ? 'amber' : _realAccentColor;

    _themeController.add(
      getThemeData(
        lightColorScheme: colorScheme,
        accentColor: accentColor,
      ),
    );
  }

  void toggle() {
    setForecastMode(!isInForecastMode);
  }

  /// The forecast accent color for use in widgets
  static const Color forecastAccentColor = Color(0xFF0D9488);
}
