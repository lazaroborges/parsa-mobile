import 'dart:async';

import 'package:parsa/core/database/services/user-setting/user_setting_service.dart';
import 'package:parsa/core/utils/shared_preferences_async.dart';
import 'package:rxdart/rxdart.dart';

class PrivateModeService {
  final UserSettingService userSettingsService;
  static const String keyCurrentPrivateMode = 'currentPrivateMode';

  PrivateModeService._(this.userSettingsService);
  static final PrivateModeService instance =
      PrivateModeService._(UserSettingService.instance);

  final _privateModeController = BehaviorSubject<bool>();
  Stream<bool> get privateModeStream => _privateModeController.stream;

  void dispose() {
    _privateModeController.close();
  }

  /// Initializes the private mode based on settings and preferences
  Future<void> initializePrivateMode() async {
    // First check if "private mode at launch" is enabled
    final privateModeAtLaunch = await getPrivateModeAtLaunch().first;

    if (privateModeAtLaunch) {
      // If enabled, always start with private mode on
      setPrivateMode(true);
    } else {
      // Otherwise, load the last state from shared preferences
      final lastPrivateMode = await SharedPreferencesAsync.instance
              .getBool(keyCurrentPrivateMode) ??
          false;
      setPrivateMode(lastPrivateMode);
    }
  }

  /// Sets the current private mode state and saves it to preferences
  void setPrivateMode(bool value) {
    _privateModeController.add(value);

    // Save the current state to shared preferences for next launch
    SharedPreferencesAsync.instance.setBool(keyCurrentPrivateMode, value);
  }

  /// Set if the app should start in private mode
  Future<int> setPrivateModeAtLaunch(bool value) async {
    // Save to database setting
    final result = await userSettingsService.setSetting(
        SettingKey.privateModeAtLaunch, value ? '1' : '0');

    // Also save to shared preferences for faster access
    await SharedPreferencesAsync.instance.setPrivateModeAtLaunch(value);

    return result;
  }

  /// Get if the app should start in private mode
  Stream<bool> getPrivateModeAtLaunch() {
    return userSettingsService
        .getSetting(SettingKey.privateModeAtLaunch)
        .map((x) => x == '1');
  }

  /// Get the current private mode setting directly from preferences
  Future<bool> getCurrentPrivateMode() async {
    return await SharedPreferencesAsync.instance
            .getBool(keyCurrentPrivateMode) ??
        false;
  }
}
