import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parsa/app/accounts/account_connection_modal.dart';
import 'package:parsa/app/accounts/account_form.dart';
import 'package:parsa/app/accounts/details/account_details.dart';
import 'package:parsa/app/home/widgets/home_drawer.dart';
import 'package:parsa/app/home/widgets/income_or_expense_card.dart';
import 'package:parsa/app/home/widgets/new_transaction_fl_button.dart';
import 'package:parsa/app/stats/stats_page.dart';
import 'package:parsa/app/stats/widgets/finance_health/finance_health_main_info.dart';
import 'package:parsa/app/stats/widgets/movements_distribution/chart_by_categories.dart';
import 'package:parsa/app/transactions/transactions.page.dart';
import 'package:parsa/core/database/services/account/account_service.dart';
import 'package:parsa/core/database/services/user-setting/user_setting_service.dart';
import 'package:parsa/core/models/account/account.dart';
import 'package:parsa/core/models/date-utils/date_period_state.dart';
import 'package:parsa/core/models/transaction/transaction_status.enum.dart';
import 'package:parsa/core/presentation/responsive/breakpoints.dart';
import 'package:parsa/core/presentation/responsive/responsive_row_column.dart';
import 'package:parsa/core/presentation/widgets/card_with_header.dart';
import 'package:parsa/core/presentation/widgets/dates/date_period_modal.dart';
import 'package:parsa/core/presentation/widgets/number_ui_formatters/currency_displayer.dart';
import 'package:parsa/core/presentation/widgets/skeleton.dart';
import 'package:parsa/core/presentation/widgets/tappable.dart';
import 'package:parsa/core/presentation/widgets/transaction_filter/transaction_filters.dart';
import 'package:parsa/core/presentation/widgets/trending_value.dart';
import 'package:parsa/core/presentation/widgets/user_avatar.dart';
import 'package:parsa/core/routes/destinations.dart';
import 'package:parsa/core/routes/route_utils.dart';
import 'package:parsa/core/services/finance_health_service.dart';
import 'package:parsa/i18n/translations.g.dart';
import 'package:parsa/app/transactions/widgets/transaction_list.dart'; // Import the TransactionListComponent

import '../../core/models/transaction/transaction_type.enum.dart';
import '../../core/presentation/app_colors.dart';

import 'package:flutter/services.dart' show rootBundle;

import 'package:parsa/core/api/fetch_user_accounts.dart';
import 'package:parsa/core/api/fetch_user_transactions.dart';

import 'package:provider/provider.dart';
import 'package:parsa/core/providers/user_data_provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DatePeriodState dateRangeService = const DatePeriodState();
  bool isLoading = false;
  bool isLoadingTransactions = true;
  BalanceType currentBalanceType = BalanceType.future;

  void _toggleBalanceType() {
    setState(() {
      currentBalanceType = BalanceType.values[
          (currentBalanceType.index + 1) % BalanceType.values.length];
    });
  }

  @override
  void initState() {
    super.initState();
  }


Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
      isLoadingTransactions = true;
    });

    try {
      await Future.wait([
        fetchUserAccounts(),
        fetchUserTransactions(context),
      ]);
    } catch (e) {
      print('Error refreshing data: $e');
      // You might want to show an error message to the user here
    } finally {
      setState(() {
        isLoading = false;
        isLoadingTransactions = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final userData = context.watch<UserDataProvider>().userData;
    print('userData: $userData');
    final t = Translations.of(context);

    final accountService = AccountService.instance;

    final hideDrawerAndFloatingButton =
        BreakPoint.of(context).isLargerOrEqualTo(BreakpointID.md);

    return Scaffold(
        appBar: EmptyAppBar(color: AppColors.of(context).light),
        floatingActionButton:
            hideDrawerAndFloatingButton ? null : const NewTransactionButton(),
        drawer: hideDrawerAndFloatingButton
            ? null
            : Drawer(
                child: Builder(builder: (context) {
                  final drawerItems = getDestinations(context,
                      showHome: false, shortLabels: false);

                  return HomeDrawer(
                    drawerActions: drawerItems,
                    onDestinationSelected: (e) {
                      Navigator.pop(context);

//                    context.router.push(drawerItems.elementAt(e).destination);
                    },
                    selectedIndex: -1,
                  );
                }),
              ),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(), // Use ClampingScrollPhysics here
            child: Column(children: [
              DefaultTextStyle.merge(
                style:
                    TextStyle(color: Theme.of(context).appBarTheme.foregroundColor),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 24),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Tappable(
                              onTap: () {
                                // No action needed
                              },
                              bgColor: Colors.transparent,
                              borderRadius: 12,
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Row(
                                  children: [
                                    if (BreakPoint.of(context)
                                        .isSmallerThan(BreakpointID.md)) ...[
                                      if (userData != null &&
                                          userData!['avatar_url'] != null)
                                        CircleAvatar(
                                          backgroundImage:
                                              NetworkImage(userData!['avatar_url']),
                                          radius: 18,
                                        )
                                      else
                                        StreamBuilder(
                                            stream: UserSettingService.instance
                                                .getSetting(SettingKey.avatar),
                                            builder: (context, snapshot) {
                                              return UserAvatar(
                                                  avatar: snapshot.data);
                                            }),
                                      const SizedBox(width: 8),
                                    ],
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _getGreeting(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                fontWeight: FontWeight.w300,
                                              ),
                                        ),
                                        StreamBuilder(
                                            stream: UserSettingService.instance
                                                .getSetting(SettingKey.userName),
                                            builder: (context, snapshot) {
                                              if (userData != null &&
                                                  userData!['first_name'] != null) {
                                                return Text(
                                                  utf8.decode(
                                                      userData!['first_name']
                                                          .toString()
                                                          .runes
                                                          .toList()),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleSmall!
                                                      .copyWith(
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: 18,
                                                      ),
                                                );
                                              }

                                              if (!snapshot.hasData) {
                                                return const Skeleton(
                                                    width: 70, height: 12);
                                              }

                                              return Text(
                                                snapshot.data!,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall!
                                                    .copyWith(
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 18,
                                                    ),
                                              );
                                            }),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                            ActionChip(
                              label: Text(dateRangeService.getText(context)),
                              backgroundColor:
                                  AppColors.of(context).primaryContainer,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                side: BorderSide(
                                  style: BorderStyle.none,
                                  color: AppColors.of(context).onPrimary,
                                ),
                              ),
                              onPressed: () {
                                openDatePeriodModal(
                                  context,
                                  DatePeriodModal(
                                    initialDatePeriod: dateRangeService.datePeriod,
                                  ),
                                ).then((value) {
                                  if (value == null) return;

                                  setState(() {
                                    dateRangeService = dateRangeService.copyWith(
                                      periodModifier: 0,
                                      datePeriod: value,
                                    );
                                  });
                                });
                              },
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        const SizedBox(height: 8),
                        StreamBuilder(
                          stream: AccountService.instance.getAccounts(),
                          builder: (context, accounts) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                totalBalanceIndicator(
                                    context, accounts, accountService),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    IncomeOrExpenseCard(
                                      type: TransactionType.I,
                                      startDate: dateRangeService.startDate,
                                      endDate: dateRangeService.endDate,
                                    ),
                                    SizedBox(
                                      width: 100,
                                      child: IncomeOrExpenseCard(
                                        type: TransactionType.E,
                                        startDate: dateRangeService.startDate,
                                        endDate: dateRangeService.endDate,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              _HorizontalScrollableAccountList(
                dateRangeService: dateRangeService,
              ),

              // Move the TransactionListComponent here
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: CardWithHeader(
                  title: t.home.last_transactions,
                  onHeaderButtonClick: () {
                    RouteUtils.pushRoute(context, TransactionsPage());
                  },
                  body: DashboardTransactionList(
                    child: TransactionListComponent(
                      heroTagBuilder: (tr) => 'dashboard-page__tr-icon-${tr.id}',
                      filters: TransactionFilters(
                        status: TransactionStatus.notIn({
                          TransactionStatus.pending,
                          TransactionStatus.voided,
                          TransactionStatus.notconsidered
                        }),
                      ),
                      limit: 5,
                      showGroupDivider: false,
                      prevPage: DashboardPage(),
                      onEmptyList: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          t.transaction.list.empty,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Add padding/spacing here

              // ------------- STATS GENERAL CARDS --------------

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
                child: ResponsiveRowColumn.withSymetricSpacing(
                  direction: BreakPoint.of(context).isLargerThan(BreakpointID.md)
                      ? Axis.horizontal
                      : Axis.vertical,
                  rowCrossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
  
                    ResponsiveRowColumnItem(
                      rowFit: FlexFit.tight,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CardWithHeader(
                              title: t.stats.by_categories,
                              body: ChartByCategories(
                                  datePeriodState: dateRangeService),
                              onHeaderButtonClick: () {
                                RouteUtils.pushRoute(
                                  context,
                                  StatsPage(
                                      dateRangeService: dateRangeService,
                                      initialIndex: 0),
                                );
                              }),
                          const SizedBox(height: 16),

                          CardWithHeader(
                            title: t.financial_health.display,
                            onHeaderButtonClick: () => RouteUtils.pushRoute(
                                context,
                                StatsPage(
                                    dateRangeService: dateRangeService,
                                    initialIndex: 2)),
                            bodyPadding: const EdgeInsets.all(16),
                            body: StreamBuilder(
                              stream: FinanceHealthService().getHealthyValue(
                                filters: TransactionFilters(
                                  minDate: dateRangeService.startDate,
                                  maxDate: dateRangeService.endDate,
                                ),
                              ),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const LinearProgressIndicator();
                                }

                                final financeHealthData = snapshot.data!;

                                return FinanceHealthMainInfo(
                                    financeHealthData: financeHealthData);
                              },
                            ),
                          ),
                          const SizedBox(height: 16),

                        ],
                      ),
                    ),
                    // ResponsiveRowColumnItem(
                    //   rowFit: FlexFit.tight,
                    //   child: Column(
                    //     mainAxisSize: MainAxisSize.min,
                    //     children: [
                    //       CardWithHeader(
                    //           title: t.stats.balance_evolution,
                    //           body: FundEvolutionLineChart(
                    //             dateRange: dateRangeService,
                    //           ),
                    //           onHeaderButtonClick: () {
                    //             RouteUtils.pushRoute(
                    //               context,
                    //               StatsPage(
                    //                   dateRangeService: dateRangeService,
                    //                   initialIndex: 2),
                    //             );
                    //           }),
                    //       const SizedBox(height: 16),
                    //       CardWithHeader(
                    //           title: t.stats.cash_flow,
                    //           body: Padding(
                    //             padding: const EdgeInsets.only(
                    //                 top: 16, left: 16, right: 16),
                    //             child: BalanceChartSmall(
                    //                 dateRangeService: dateRangeService),
                    //           ),
                    //           onHeaderButtonClick: () {
                    //             RouteUtils.pushRoute(
                    //               context,
                    //               StatsPage(
                    //                   dateRangeService: dateRangeService,
                    //                   initialIndex: 3),
                    //             );
                    //           }),
                    //     ],
                    //   ),
                    // )
                  ],
                ),
              ),
            ]),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat);
  }

  Widget totalBalanceIndicator(
    BuildContext context,
    AsyncSnapshot<List<Account>> accounts,
    AccountService accountService,
  ) {
    final t = Translations.of(context);
    final userData = context.watch<UserDataProvider>().userData;

    return GestureDetector(
      onTap: _toggleBalanceType,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Tooltip(
            message: t.home.total_balance_tooltip,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currentBalanceType.getTitle(context),
                  style: Theme.of(context).textTheme.labelSmall!,
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.all(0),
                  child: Icon(
                    Icons.info_outline,
                    size: 14,
                    color: Theme.of(context).textTheme.labelSmall!.color,
                  ),
                ),
              ],
            ),
          ),
          if (!accounts.hasData) ...[
            const Skeleton(width: 70, height: 54),
          ],
          if (accounts.hasData) ...[
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 0.1),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: switch (currentBalanceType) {
                BalanceType.available => _buildBalanceDisplay(
                    context,
                    userData?['balance_available']?.toDouble() ?? 0.0,
                    key: ValueKey('available-balance-${currentBalanceType.index}'),
                  ),
                BalanceType.total => _buildBalanceDisplay(
                    context,
                    userData?['balance_total']?.toDouble() ?? 0.0,
                    key: ValueKey('total-balance-${currentBalanceType.index}'),
                  ),
                BalanceType.future => StreamBuilder(
                    key: ValueKey('future-balance-${currentBalanceType.index}'),
                    stream: accountService.getAccountsMoneyWidget(
                      accountIds: accounts.data!.map((e) => e.id).toList(),
                    ),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Skeleton(width: 90, height: 40);
                      }
                      return _buildBalanceDisplay(context, snapshot.data!);
                    },
                  ),
              },
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildBalanceDisplay(BuildContext context, double balance, {Key? key}) {
    final isNegative = balance < 0;
    double screenWidth = MediaQuery.of(context).size.width;
    double widthMultiplier = 0.45;

    return Container(
      key: key,
      width: screenWidth * widthMultiplier,
      height: 54, // Fixed height to prevent layout shifts
      alignment: Alignment.centerLeft,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: CurrencyDisplayer(
          amountToConvert: balance.abs(),
          integerStyle: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            color: isNegative
                ? Colors.red
                : Theme.of(context).textTheme.titleLarge!.color,
          ),
        ),
      ),
    );
  }

  Widget buildAccountList(List<Account> accounts) {
    return Builder(
      builder: (context) {
        if (accounts.isEmpty) {
          return Column(
            children: [
              Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        t.home.no_accounts,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t.home.no_accounts_descr,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      FilledButton(
                          onPressed: () => RouteUtils.pushRoute(
                              context, const AccountFormPage()),
                          child: Text(t.account.form.create))
                    ],
                  ))
            ],
          );
        }

        return ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: accounts.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) {
              return const Divider(indent: 56);
            },
            itemBuilder: (context, index) {
              final account = accounts[index];

              return ListTile(
                onTap: () => RouteUtils.pushRoute(
                    context,
                    AccountDetailsPage(
                        account: account,
                        accountIconHeroTag:
                            'dashboard-page__account-icon-${account.id}')),
                leading: Hero(
                    tag: 'dashboard-page__account-icon-${account.id}',
                    child: account.displayIcon(context)),
                trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      StreamBuilder(
                          initialData: 0.0,
                          stream: AccountService.instance
                              .getAccountMoney(account: account),
                          builder: (context, snapshot) {
                            return CurrencyDisplayer(
                              amountToConvert: snapshot.data!,
                              currency: account.currency,
                            );
                          }),
                      StreamBuilder(
                          initialData: 0.0,
                          stream: AccountService.instance
                              .getAccountsMoneyVariation(
                                  accounts: [account],
                                  startDate: dateRangeService.startDate,
                                  endDate: dateRangeService.endDate,
                                  convertToPreferredCurrency: false),
                          builder: (context, snapshot) {
                            return TrendingValue(
                              percentage: snapshot.data!,
                              decimalDigits: 0,
                            );
                          }),
                    ]),
                title: Text(account.name),
              );
            });
      },
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Bom dia!';
    } else if (hour < 18) {
      return 'Boa tarde!';
    } else {
      return 'Boa noite!';
    }
  }
}

class _HorizontalScrollableAccountList extends StatefulWidget {
  const _HorizontalScrollableAccountList({
    required this.dateRangeService,
    super.key,
  });

  final DatePeriodState dateRangeService;

  @override
  State<_HorizontalScrollableAccountList> createState() => _HorizontalScrollableAccountListState();
}

class _HorizontalScrollableAccountListState extends State<_HorizontalScrollableAccountList> {
  final Map<String, String> _iconPathCache = {};

  Future<String> _getIconPath(String iconId) async {
    if (_iconPathCache.containsKey(iconId)) {
      return _iconPathCache[iconId]!;
    }

    final defaultPath = 'assets/png_icons/$iconId.png';
    final fallbackPath = 'assets/png_icons/1.png';

    try {
      await rootBundle.load(defaultPath);
      _iconPathCache[iconId] = defaultPath;
      return defaultPath;
    } catch (_) {
      _iconPathCache[iconId] = fallbackPath;
      return fallbackPath;
    }
  }

  Widget _buildAccountIcon(String iconId) {
    return FutureBuilder<String>(
      future: _getIconPath(iconId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Image.asset(
            'assets/png_icons/1.png',
            width: 45,
            height: 45,
            fit: BoxFit.contain,
          );
        }
        
        return Image.asset(
          snapshot.data!,
          width: 45,
          height: 45,
          fit: BoxFit.contain,
          cacheWidth: 90, // 2x for high DPI
          cacheHeight: 90,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: StreamBuilder<List<Account>>(
          stream: AccountService.instance.getAccounts(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }

            final accounts = snapshot.data!;

            return Row(
              children: [
                ...accounts.map((account) {
                  return Card(
                    margin: const EdgeInsets.only(right: 8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Tappable(
                      onTap: () => RouteUtils.pushRoute(
                        context,
                        AccountDetailsPage(
                          account: account,
                          accountIconHeroTag: null, // Remove Hero tag
                        ),
                      ),
                      bgColor: Colors.transparent,
                      borderRadius: 24,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          width: 220,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  _buildAccountIcon(account.iconId),
                                  const SizedBox(width: 2),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        account.name.length > 20
                                            ? '${account.name.substring(0, 20)}'
                                            : account.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium!
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Text(
                                        account.type.title(context),
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium!,
                                      )
                                    ],
                                  )
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CurrencyDisplayer(
                                    amountToConvert: account.balance,
                                    currency: account.currency,
                                    integerStyle: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  if (account.isOpenFinance == true)
                                    SizedBox(
                                      width: 92,
                                      child: Image.asset(
                                        'assets/icons/supported_selectable_icons/logos/open/logo.png',
                                      ),
                                    )
                                  else
                                    const SizedBox(width: 105),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
                Opacity(
                  opacity: 0.6,
                  child: Tappable(
                    onTap: () {
                      RouteUtils.pushRoute(
                          context, const AccountConnectionModal());
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        width: 2,
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    child: Card(
                      elevation: 0,
                      color: Colors.transparent,
                      margin: const EdgeInsets.all(0),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          width: 200,
                          height: 93.3, // 127.3 - 32 - 2
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(t.account.form.create),
                              const SizedBox(height: 8),
                              const Icon(Icons.add),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}

class EmptyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Color color;

  const EmptyAppBar({required this.color, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
    );
  }

  @override
  Size get preferredSize => const Size(0.0, 0.0);
}

class DashboardTransactionList extends StatelessWidget {
  final TransactionListComponent child;

  const DashboardTransactionList({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TransactionListComponent(
      heroTagBuilder: child.heroTagBuilder,
      filters: child.filters,
      limit: child.limit,
      showGroupDivider: child.showGroupDivider,
      prevPage: child.prevPage,
      onLongPress: (_) {}, // This effectively disables the long press action
      onEmptyList: child.onEmptyList,
    );
  }
}

enum BalanceType {
  available,
  total,
  future;

  String getTitle(BuildContext context) {
    final t = Translations.of(context);
    switch (this) {
      case BalanceType.available:
        return 'Saldo Total Disponível';
      case BalanceType.total:
        return 'Saldo Total com Investimentos';
      case BalanceType.future:
        return t.home.total_balance;
    }
  }
}

