import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:parsa/core/models/dashboard/dashboard_card_config.dart';
import 'package:parsa/core/utils/shared_preferences_async.dart' as app_prefs;

class DashboardCardsService {
  DashboardCardsService._privateConstructor();

  static final DashboardCardsService instance =
      DashboardCardsService._privateConstructor();

  static const String _prefsKey = 'dashboard_cards_config';

  List<DashboardCardConfig> _defaultConfig() {
    return [
      DashboardCardConfig(key: DashboardCardKey.accounts, order: 0),
      DashboardCardConfig(
          key: DashboardCardKey.creditCards, order: 1, enabled: false),
      DashboardCardConfig(key: DashboardCardKey.lastTransactions, order: 2),
      DashboardCardConfig(key: DashboardCardKey.byCategories, order: 3),
      DashboardCardConfig(key: DashboardCardKey.cashFlow, order: 4),
      DashboardCardConfig(key: DashboardCardKey.byTags, order: 5),
      DashboardCardConfig(key: DashboardCardKey.budgets, order: 6),
    ];
  }

  Future<List<DashboardCardConfig>> getCardsConfig() async {
    final prefs = app_prefs.SharedPreferencesAsync.instance;
    final jsonString = await prefs.getString(_prefsKey);

    if (jsonString != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        final configs =
            jsonList.map((json) => DashboardCardConfig.fromJson(json)).toList();

        final defaultKeys = _defaultConfig().map((c) => c.key).toSet();
        final currentKeys = configs.map((c) => c.key).toSet();
        final missingKeys = defaultKeys.difference(currentKeys);

        if (missingKeys.isNotEmpty) {
          int maxOrder = configs.map((c) => c.order).maxOrNull ?? -1;
          for (var key in missingKeys) {
            final defaultConfig =
                _defaultConfig().firstWhere((c) => c.key == key);
            configs.add(DashboardCardConfig(
                key: key, order: ++maxOrder, enabled: defaultConfig.enabled));
          }
          await saveCardsConfig(configs);
        }

        configs.sort((a, b) => a.order.compareTo(b.order));
        return configs;
      } catch (e) {
        await prefs.remove(_prefsKey);
        return _defaultConfig();
      }
    } else {
      return _defaultConfig();
    }
  }

  Future<void> saveCardsConfig(List<DashboardCardConfig> configs) async {
    final prefs = app_prefs.SharedPreferencesAsync.instance;
    final jsonString =
        jsonEncode(configs.map((config) => config.toJson()).toList());
    await prefs.setString(_prefsKey, jsonString);
  }
}
