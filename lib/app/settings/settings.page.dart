import 'package:flutter/material.dart';
import 'package:parsa/app/accounts/all_accounts.page.dart';
import 'package:parsa/app/budgets/budgets.page.dart';

import 'package:parsa/app/settings/about.page.dart';
import 'package:parsa/app/settings/preferences_settings.page.dart';
import 'package:parsa/app/settings/backup_settings_page.dart';
import 'package:parsa/app/settings/subscriptions/can.dart';

import 'package:parsa/app/settings/widgets/setting_card_item.dart';
import 'package:parsa/app/stats/stats.page.dart';
import 'package:parsa/app/tags/tag_list.page.dart';
import 'package:parsa/app/transactions/recurrent_transactions_page.dart';
import 'package:parsa/core/presentation/responsive/breakpoints.dart';
import 'package:parsa/core/routes/route_utils.dart';
import 'package:parsa/i18n/translations.g.dart';
import 'package:parsa/core/services/auth/auth_methods.dart';
import 'package:parsa/core/services/auth/auth0_class.dart';
import 'package:parsa/main.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final auth0 = Auth0Provider.instance.auth0;
    final t = Translations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.more.title_long),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                  top: 8, left: 16, right: 16, bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  SettingCardItem(
                    title: t.settings.title_long,
                    subtitle: t.settings.description,
                    icon: Icons.palette_outlined,
                    mainAxis: Axis.horizontal,
                    onTap: () => RouteUtils.pushRoute(
                        context, const PreferencesSettingsPage()),
                  ),
                  const SizedBox(height: 8),
                  SettingCardItem(
                    title: t.more.data.display,
                    subtitle: t.more.data.display_descr,
                    icon: Icons.storage_rounded,
                    mainAxis: Axis.horizontal,
                    onTap: () => RouteUtils.pushRoute(
                        context, const BackupSettingsPage()),
                  ),
                  const SizedBox(height: 8),
                  SettingCardItem(
                    title: t.more.about_us.display,
                    subtitle: t.more.about_us.description,
                    icon: Icons.info_outline_rounded,
                    mainAxis: Axis.horizontal,
                    onTap: () =>
                        RouteUtils.pushRoute(context, const AboutPage()),
                  ),
                  const SizedBox(height: 8),
                  SettingCardItem(
                    title: t.more.subscribe.display,
                    subtitle: t.more.subscribe.description,
                    icon: Icons.subscriptions,
                    mainAxis: Axis.horizontal,
                    onTap: () =>
                        ServerHealthCheck.checkServerHealthAndNavigate(context),
                  ),
                  //bring back the donate button
                  if (BreakPoint.of(context)
                      .isSmallerThan(BreakpointID.md)) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: SettingCardItem(
                            title: t.stats.title,
                            icon: Icons.area_chart_rounded,
                            onTap: () =>
                                tabsPageKey.currentState?.navigateToTab(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SettingCardItem(
                            title: t.budgets.title,
                            icon: Icons.pie_chart_rounded,
                            onTap: () => RouteUtils.pushRoute(
                              context,
                              const BudgetsPage(),
                            ),
                          ),
                        ),
                        // const SizedBox(width: 8),
                        // Expanded(
                        //   child: SettingCardItem(
                        //     title: t.recurrent_transactions.title_short,
                        //     icon: Icons.repeat_rounded,
                        //     onTap: () => RouteUtils.pushRoute(
                        //         context, const RecurrentTransactionPage()),
                        //   ),
                        // ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: SettingCardItem(
                          title: t.tags.display(n: 10),
                          icon: Icons.label_outline_rounded,
                          onTap: () => RouteUtils.pushRoute(
                              context, const TagListPage()),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SettingCardItem(
                          title: t.general.accounts,
                          icon: Icons.account_balance_wallet_rounded,
                          onTap: () => RouteUtils.pushRoute(
                              context, const AllAccountsPage()),
                        ),
                      ),
                      if (BreakPoint.of(context)
                          .isLargerThan(BreakpointID.sm)) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: SettingCardItem(
                            title: t.recurrent_transactions.title_short,
                            icon: Icons.repeat_rounded,
                            onTap: () => RouteUtils.pushRoute(
                                context, const RecurrentTransactionPage()),
                          ),
                        ),
                      ]
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Logout button styled similarly to the other setting items
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white, // Background color
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black), // Black border
              ),
              child: SizedBox(
                width: double.infinity,
                child: Material(
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => AuthMethods.logout(context, auth0),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical:
                            16.0, // Adjust vertical padding for a button-like feel
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Icon(Icons.logout, color: Colors.black),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Fazer logout',
                            style: TextStyle(
                              color: Colors.black, // White text to match style
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16), // Add some space from the bottom
        ],
      ),
    );
  }
}
