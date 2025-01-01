import 'package:shared_preferences/shared_preferences.dart';

class FeatureAnnouncementService {
  static const String _storageKey = 'has_seen_feature_announcement';
  
  static Future<bool> hasSeenAnnouncement() async {
    final prefs = await SharedPreferences.getInstance();
    print('hasSeenAnnouncement: ${prefs.getBool(_storageKey)}');
    return prefs.getBool(_storageKey) ?? false;
  }

  static Future<void> markAnnouncementAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_storageKey, true);
  }
}