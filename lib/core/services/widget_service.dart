import 'package:shared_preferences/shared_preferences.dart';

class WidgetService {
  static const String _groupIdentifier = 'group.com.parsa.app';
  
  static Future<void> updateWidgetData({
    required double availableBalance,
    required double income,
    required double expenses,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Store the data in shared preferences
    await prefs.setDouble('availableBalance', availableBalance);
    await prefs.setDouble('income', income);
    await prefs.setDouble('expenses', expenses);
    
    // Trigger widget refresh
    // Note: This is handled automatically by iOS when shared preferences are updated
  }
} 