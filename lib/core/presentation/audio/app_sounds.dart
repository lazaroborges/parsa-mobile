import 'package:just_audio/just_audio.dart';

/// AppSounds provides a centralized way to access and play sound assets in the application.
///
/// This class defines constants for sound file paths and provides utility methods
/// to play sounds using the just_audio package.
class AppSounds {
  // Private constructor to prevent instantiation
  AppSounds._();

  /// Audio player instance for playing sounds
  static final AudioPlayer _audioPlayer = AudioPlayer();

  // Define sound asset paths as constants
  // Note: Add actual sound files to the assets/sounds directory and update these paths

  /// Sound played on successful operations
  static const String success = 'assets/sounds/success.mp3';

  /// Sound played on error or failed operations
  static const String error = 'assets/sounds/error.mp3';

  /// Sound played on notification
  static const String notification = 'assets/sounds/notification.mp3';

  /// Sound played when transaction is added
  static const String transactionAdded = 'assets/sounds/transaction_added.mp3';

  /// Sound played when clicking buttons
  static const String buttonClick = 'assets/sounds/button_click.mp3';

  /// Sound played when swiping cards
  static const String swipe = 'assets/sounds/swipe.mp3';

  /// Plays the specified sound once.
  ///
  /// [assetPath] is the path to the sound asset.
  /// [volume] is the playback volume between 0.0 and 1.0.
  static Future<void> play(String assetPath, {double volume = 1.0}) async {
    try {
      await _audioPlayer.setAsset(assetPath);
      await _audioPlayer.setVolume(volume);
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  /// Plays the success sound.
  static Future<void> playSuccess({double volume = 0.6}) async {
    await play(success, volume: volume);
  }

  /// Plays the error sound.
  static Future<void> playError({double volume = 1.0}) async {
    await play(error, volume: volume);
  }

  /// Plays the notification sound.
  static Future<void> playNotification({double volume = 1.0}) async {
    await play(notification, volume: volume);
  }

  /// Plays the transaction added sound.
  static Future<void> playTransactionAdded({double volume = 1.0}) async {
    await play(transactionAdded, volume: volume);
  }

  /// Plays the button click sound.
  static Future<void> playButtonClick({double volume = 1.0}) async {
    await play(buttonClick, volume: volume);
  }

  /// Plays the swipe sound.
  static Future<void> playSwipe({double volume = 1.0}) async {
    await play(swipe, volume: volume);
  }

  /// Disposes the audio player resources.
  ///
  /// Call this method when the app is being closed or the audio
  /// functionality is no longer needed.
  static Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}
