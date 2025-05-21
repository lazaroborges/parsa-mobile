import 'package:shared_preferences/shared_preferences.dart';
import 'app_sound_player.dart';

/// SoundSettings manages user preferences for sound in the application.
///
/// This class provides methods to read and write sound settings to SharedPreferences,
/// ensuring that user preferences persist across app launches.
class SoundSettings {
  // Private constructor to prevent instantiation
  SoundSettings._();

  // Keys for SharedPreferences
  static const String _soundEnabledKey = 'sound_enabled';

  /// Initializes sound settings by loading them from SharedPreferences.
  ///
  /// This should be called early in the app's lifecycle, such as during
  /// app initialization or in the main method.
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final soundEnabled =
        prefs.getBool(_soundEnabledKey) ?? true; // Default to true
    AppSoundPlayer.soundEnabled = soundEnabled;
  }

  /// Gets whether sounds are enabled.
  static Future<bool> getSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_soundEnabledKey) ?? true; // Default to true
  }

  /// Sets whether sounds are enabled and persists the setting.
  ///
  /// [enabled] determines whether sounds should be enabled or disabled.
  static Future<void> setSoundEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundEnabledKey, enabled);
    AppSoundPlayer.soundEnabled = enabled;
  }

  /// Toggles the sound enabled setting and returns the new state.
  ///
  /// This is a convenience method for toggling the sound on/off.
  static Future<bool> toggleSoundEnabled() async {
    final currentValue = await getSoundEnabled();
    final newValue = !currentValue;
    await setSoundEnabled(newValue);
    return newValue;
  }
}
