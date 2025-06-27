import 'package:flutter/material.dart';
import 'package:parsa/core/models/dashboard/dashboard_card_config.dart';
import 'package:parsa/core/presentation/widgets/monekin_reorderable_list.dart';
import 'package:parsa/core/services/dashboard_cards_service.dart';
import 'package:parsa/i18n/translations.g.dart';

class DashboardCardsSettingsPage extends StatefulWidget {
  const DashboardCardsSettingsPage({super.key});

  @override
  State<DashboardCardsSettingsPage> createState() =>
      _DashboardCardsSettingsPageState();
}

class _DashboardCardsSettingsPageState
    extends State<DashboardCardsSettingsPage> {
  late Future<List<DashboardCardConfig>> _cardsConfigFuture;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  void _loadConfig() {
    _cardsConfigFuture = DashboardCardsService.instance.getCardsConfig();
  }

  Future<void> _saveConfig(List<DashboardCardConfig> configs) async {
    for (var i = 0; i < configs.length; i++) {
      configs[i].order = i;
    }
    await DashboardCardsService.instance.saveCardsConfig(configs);
    setState(() {
      _loadConfig();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(t.settings.dashboard.title)),
      body: FutureBuilder<List<DashboardCardConfig>>(
        future: _cardsConfigFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final cards = snapshot.data!
              .where((card) => card.key != DashboardCardKey.creditCards)
              .toList();

          return MonekinReorderableList(
            totalItemCount: cards.length,
            isOrderEnabled: true,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, index) {
              final card = cards[index];
              return Row(
                key: ValueKey(card.key.name),
                children: [
                  Expanded(
                    child: SwitchListTile(
                      value: card.enabled,
                      onChanged: (isEnabled) {
                        setState(() {
                          card.enabled = isEnabled;
                        });
                        _saveConfig(cards);
                      },
                      title: Text(card.key.title),
                      secondary: Icon(card.key.icon),
                    ),
                  ),
                  ReorderableDragStartListener(
                    index: index,
                    child: const Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: Icon(Icons.drag_handle),
                    ),
                  )
                ],
              );
            },
            onReorder: (oldIndex, newIndex) {
              if (newIndex > oldIndex) {
                newIndex -= 1;
              }
              final item = cards.removeAt(oldIndex);
              cards.insert(newIndex, item);
              _saveConfig(cards);
            },
          );
        },
      ),
    );
  }
}
