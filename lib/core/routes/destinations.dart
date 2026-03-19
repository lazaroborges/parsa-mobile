import 'package:flutter/material.dart';
import 'package:parsa/app/budgets/budgets.page.dart';
import 'package:parsa/app/home/dashboard.page.dart';
import 'package:parsa/app/settings/settings.page.dart';
import 'package:parsa/app/stats/stats.page.dart';
import 'package:parsa/app/transactions/transactions.page.dart';
import 'package:parsa/core/presentation/responsive/breakpoints.dart';
import 'package:parsa/i18n/translations.g.dart';
import 'package:parsa/core/models/date-utils/date_period_state.dart';

enum AppMenuDestinationsID {
  dashboard,
  budgets,
  transactions,
  recurrentTransactions,
  accounts,
  stats,
  forecast,
  settings,
  categories,
}

class MainMenuDestination {
  const MainMenuDestination(
    this.id, {
    required this.destination,
    required this.label,
    required this.icon,
    this.selectedIcon,
  });

  final AppMenuDestinationsID id;
  final String label;
  final IconData icon;
  final IconData? selectedIcon;

  final Widget destination;

  NavigationDestination toNavigationDestinationWidget() {
    return NavigationDestination(
      icon: Icon(icon),
      selectedIcon: Icon(selectedIcon ?? icon),
      label: label,
    );
  }

  NavigationDrawerDestination toNavigationDrawerDestinationWidget() {
    return NavigationDrawerDestination(
      icon: Icon(icon),
      selectedIcon: Icon(selectedIcon ?? icon),
      label: Text(label),
    );
  }

  NavigationRailDestination toNavigationRailDestinationWidget() {
    return NavigationRailDestination(
      icon: Icon(icon),
      selectedIcon: Icon(selectedIcon ?? icon),
      label: Text(
        label,
        textAlign: TextAlign.center,
        overflow: TextOverflow.fade,
        softWrap: false,
      ),
    );
  }
}

List<MainMenuDestination> getAllDestinations(
  BuildContext context, {
  required bool shortLabels,
}) {
  final t = Translations.of(context);

  return <MainMenuDestination>[
    MainMenuDestination(
      AppMenuDestinationsID.dashboard,
      label: t.home.title,
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      destination: const DashboardPage(),
    ),
    MainMenuDestination(
      AppMenuDestinationsID.budgets,
      label: t.budgets.title,
      icon: Icons.calculate_outlined,
      selectedIcon: Icons.calculate,
      destination: const BudgetsPage(),
    ),
    // MainMenuDestination(
    //   AppMenuDestinationsID.stats,
    //   label: t.general.accounts,
    //   icon: Icons.account_balance_rounded,
    //   destination: const StatsPage(),
    // ),
    MainMenuDestination(
      AppMenuDestinationsID.transactions,
      label: t.transaction.display(n: 10),
      icon: Icons.app_registration_rounded,
      destination: const TransactionsPage(),
    ),
    /*   MainMenuDestination(
      AppMenuDestinationsID.recurrentTransactions,
      label: shortLabels
          ? t.recurrent_transactions.title_short
          : t.recurrent_transactions.title,
      icon: Icons.auto_mode_rounded,
      destination: const RecurrentTransactionPage(),
    ), */
    MainMenuDestination(
      AppMenuDestinationsID.stats,
      label: t.stats.title,
      icon: Icons.auto_graph_rounded,
      destination: const StatsPage(dateRangeService: DatePeriodState()),
    ),
    const MainMenuDestination(
      AppMenuDestinationsID.forecast,
      label: 'Previsões',
      icon: Icons.auto_awesome,
      selectedIcon: Icons.auto_awesome,
      destination: SizedBox(), // toggle action, not a page
    ),
    MainMenuDestination(
      AppMenuDestinationsID.settings,
      label: t.more.title,
      selectedIcon: Icons.more_horiz_rounded,
      icon: Icons.more_horiz_rounded,
      destination: const SettingsPage(),
    ),
  ];
}

List<MainMenuDestination> getDestinations(
  BuildContext context, {
  required bool shortLabels,
  bool showHome = true,
}) {
  final bool isMobileMode =
      BreakPoint.of(context).isSmallerThan(BreakpointID.md);

  var toReturn = getAllDestinations(context, shortLabels: shortLabels);

  if (!showHome) {
    toReturn = toReturn
        .where((element) => element.id != AppMenuDestinationsID.dashboard)
        .toList();
  }

  if (isMobileMode) {
    toReturn = toReturn
        .where((element) => [
              AppMenuDestinationsID.dashboard, // 0
              AppMenuDestinationsID.transactions, // 1
              AppMenuDestinationsID.stats, // 2
              AppMenuDestinationsID.forecast, // 3
              AppMenuDestinationsID.settings, // 4
            ].contains(element.id))
        .toList();
  }

  return toReturn;
}
