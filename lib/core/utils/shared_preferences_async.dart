import 'package:shared_preferences/shared_preferences.dart';

/// A wrapper around SharedPreferences that provides a consistent async API
class SharedPreferencesAsync {
  // Singleton pattern
  SharedPreferencesAsync._();
  static final SharedPreferencesAsync _instance = SharedPreferencesAsync._();
  static SharedPreferencesAsync get instance => _instance;

  // Keys for preferences
  static const String keyPrivateModeAtLaunch = 'privateModeAtLaunch';
  static const String keyBalanceType = 'balanceType';
  static const String keyOnboarded = 'onboarded';
  static const String keyIntakeCompleted = 'intakeCompleted';

  /// Get the shared preferences instance
  Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  /// Set a boolean value
  Future<bool> setBool(String key, bool value) async {
    final prefs = await _getPrefs();
    return prefs.setBool(key, value);
  }

  /// Get a boolean value
  Future<bool?> getBool(String key) async {
    final prefs = await _getPrefs();
    return prefs.getBool(key);
  }

  /// Set a string value
  Future<bool> setString(String key, String value) async {
    final prefs = await _getPrefs();
    return prefs.setString(key, value);
  }

  /// Get a string value
  Future<String?> getString(String key) async {
    final prefs = await _getPrefs();
    return prefs.getString(key);
  }

  /// Remove a value
  Future<bool> remove(String key) async {
    final prefs = await _getPrefs();
    return prefs.remove(key);
  }

  /// Clear all values except those in the allow list
  Future<bool> clear({List<String>? allowList}) async {
    final prefs = await _getPrefs();

    if (allowList != null && allowList.isNotEmpty) {
      // Save values from the allow list
      final Map<String, dynamic> savedValues = {};
      for (final key in allowList) {
        if (prefs.containsKey(key)) {
          final value = prefs.get(key);
          if (value != null) {
            savedValues[key] = value;
          }
        }
      }

      // Clear all preferences
      await prefs.clear();

      // Restore allowed values
      for (final entry in savedValues.entries) {
        final key = entry.key;
        final value = entry.value;

        if (value is bool) {
          await prefs.setBool(key, value);
        } else if (value is String) {
          await prefs.setString(key, value);
        } else if (value is int) {
          await prefs.setInt(key, value);
        } else if (value is double) {
          await prefs.setDouble(key, value);
        } else if (value is List<String>) {
          await prefs.setStringList(key, value);
        }
      }

      return true;
    }

    return prefs.clear();
  }

  // Convenience methods for our specific preferences

  /// Set private mode at launch preference
  Future<bool> setPrivateModeAtLaunch(bool value) async {
    final prefs = await _getPrefs();
    return prefs.setBool(keyPrivateModeAtLaunch, value);
  }

  /// Get private mode at launch preference
  Future<bool> getPrivateModeAtLaunch() async {
    final prefs = await _getPrefs();
    return prefs.getBool(keyPrivateModeAtLaunch) ?? false;
  }

  /// Set balance type preference
  Future<bool> setBalanceType(String value) async {
    final prefs = await _getPrefs();
    return prefs.setString(keyBalanceType, value);
  }

  /// Get balance type preference
  Future<String> getBalanceType() async {
    final prefs = await _getPrefs();
    return prefs.getString(keyBalanceType) ?? 'available';
  }

  /// Set onboarded preference
  Future<bool> setOnboarded(bool value) async {
    final prefs = await _getPrefs();
    return prefs.setBool(keyOnboarded, value);
  }

  /// Get onboarded preference
  Future<bool> getOnboarded() async {
    final prefs = await _getPrefs();
    return prefs.getBool(keyOnboarded) ?? false;
  }

  /// Set intake form completion status
  Future<bool> setIntakeCompleted(bool value) async {
    final prefs = await _getPrefs();
    return prefs.setBool(keyIntakeCompleted, value);
  }

  /// Get intake form completion status
  Future<bool> getIntakeCompleted() async {
    final prefs = await _getPrefs();
    return prefs.getBool(keyIntakeCompleted) ?? false;
  }
}
