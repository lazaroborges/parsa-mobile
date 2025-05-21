import 'app_sounds.dart';

/// AppSoundPlayer is a utility class that provides methods to play sounds in the application.
///
/// This class is a wrapper around AppSounds to provide a more convenient interface for
/// playing sounds in different contexts of the application.
class AppSoundPlayer {
  // Private constructor to prevent instantiation
  AppSoundPlayer._();

  // Flag to enable/disable sounds
  static bool _soundEnabled = true;

  /// Gets whether sounds are enabled.
  static bool get soundEnabled => _soundEnabled;

  /// Sets whether sounds are enabled.
  static set soundEnabled(bool value) {
    _soundEnabled = value;
  }

  /// Plays a sound for a successful operation.
  ///
  /// This can be used when a user completes an action successfully,
  /// such as saving a form or completing a transaction.
  static Future<void> playSuccessSound() async {
    if (!_soundEnabled) return;
    await AppSounds.playSuccess();
  }

  /// Plays a sound for an error or failed operation.
  ///
  /// This can be used when an operation fails or when showing an error message.
  static Future<void> playErrorSound() async {
    if (!_soundEnabled) return;
    await AppSounds.playError();
  }

  /// Plays a notification sound.
  ///
  /// This can be used when a notification is received or displayed.
  static Future<void> playNotificationSound() async {
    if (!_soundEnabled) return;
    await AppSounds.playNotification();
  }

  /// Plays a sound when a transaction is added.
  ///
  /// This can be used when a user adds a new transaction to the system.
  static Future<void> playTransactionAddedSound() async {
    if (!_soundEnabled) return;
    await AppSounds.playTransactionAdded();
  }

  /// Plays a sound when a button is clicked.
  ///
  /// This can be used for button clicks throughout the app for consistent feedback.
  static Future<void> playButtonClickSound() async {
    if (!_soundEnabled) return;
    await AppSounds.playButtonClick(
        volume: 0.5); // Lower volume for button clicks
  }

  /// Plays a sound when swiping cards or other elements.
  ///
  /// This can be used when a user swipes between cards or screens.
  static Future<void> playSwipeSound() async {
    if (!_soundEnabled) return;
    await AppSounds.playSwipe();
  }
}
