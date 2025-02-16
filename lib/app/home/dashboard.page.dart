import 'dart:async';
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
import 'package:parsa/app/stats/widgets/income_expense_comparason.dart';
import 'package:parsa/app/stats/widgets/movements_distribution/chart_by_categories.dart';
import 'package:parsa/app/transactions/transactions.page.dart';
import 'package:parsa/core/api/fetch_user_data_server.dart';
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
import 'package:parsa/core/presentation/widgets/feature_announcement_modal.dart';
import 'package:in_app_review/in_app_review.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DatePeriodState dateRangeService = const DatePeriodState();
  bool isLoading = false;
  bool isLoadingTransactions = true;
  BalanceType currentBalanceType = BalanceType.available;

  void _toggleBalanceType() {
    setState(() {
      currentBalanceType = BalanceType.values[
          (currentBalanceType.index + 1) % BalanceType.values.length];
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeDashboard();
  }

  Future<void> _initializeDashboard() async {
    try {
      // Ensure we check the announcement first
      if (mounted) {
        await FeatureAnnouncementModal.showIfNeeded(context);
      }
      
      // Then fetch data
      await _refreshData();
      
      // Add small delay to ensure userData is loaded and UI is stable
      if (mounted) {
        await Future.delayed(const Duration(seconds: 2));
        await _checkAndShowReviewDialog();
      }
    } catch (e) {
      print('Error in initialization: $e');
    }
  }

  Future<void> _refreshData() async {
    if (!mounted) return;
    
    setState(() {
      isLoading = true;
      isLoadingTransactions = true;
    });

    try {
      await Future.wait([
        fetchUserAccounts(),
          fetchUserTransactions(null),
      ]);
      unawaited(fetchUserDataAtServer());  // Trul
    } catch (e) {
      print('Error refreshing data: $e');
      // You might want to show an error message to the user here
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
          isLoadingTransactions = false;
        });
      }
    }
  }

  Future<void> _checkAndShowReviewDialog() async {
    final userData = context.read<UserDataProvider>().userData;
    
    if (userData != null && userData['ask_feedback'] == true) {
      final InAppReview inAppReview = InAppReview.instance;

      if (await inAppReview.isAvailable()) {
        // Request review
        await inAppReview.requestReview();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = context.watch<UserDataProvider>().userData;
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
                        
                        
                        if (true) ...[
                          const SizedBox(height: 16),
                          StreamBuilder<double>(
                            stream: AccountService.instance.getAccountsBalance(
                              filters: TransactionFilters(
                                minDate: dateRangeService.startDate,
                                maxDate: dateRangeService.endDate,
                                transactionTypes: [TransactionType.I],
                              ),
                            ),
                            builder: (context, incomeSnapshot) {
                              return StreamBuilder<double>(
                                stream: AccountService.instance.getAccountsBalance(
                                  filters: TransactionFilters(
                                    minDate: dateRangeService.startDate,
                                    maxDate: dateRangeService.endDate,
                                    transactionTypes: [TransactionType.E],
                                  ),
                                ),
                                builder: (context, expenseSnapshot) {
                                  if (!incomeSnapshot.hasData || !expenseSnapshot.hasData) {
                                    return const LinearProgressIndicator();
                                  }

                                  final income = incomeSnapshot.data!.abs();
                                  final expenses = expenseSnapshot.data!.abs();
                                  final percentage = income > 0 ? (expenses / income) : 0.0;

                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                                    width: double.infinity,
                                    child: Column(
                                      children: [
                                        TweenAnimationBuilder<double>(
                                          duration: const Duration(milliseconds: 1500),
                                          curve: Curves.easeInOut,
                                          tween: Tween<double>(
                                            begin: 0,
                                            end: percentage,
                                          ),
                                          builder: (context, value, child) {
                                            return ClipRRect(
                                              borderRadius: BorderRadius.circular(4),
                                              child: LinearProgressIndicator(
                                                value: value,
                                                backgroundColor: Colors.green.withOpacity(0.9),
                                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                                                minHeight: 16,
                                              ),
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 2),
                                        TweenAnimationBuilder<double>(
                                          duration: const Duration(milliseconds: 1500),
                                          curve: Curves.easeInOut,
                                          tween: Tween<double>(
                                            begin: 0,
                                            end: percentage,
                                          ),
                                          builder: (context, value, child) {
                                            return Text(
                                              '${(value * 100).toStringAsFixed(1)}% dos rendimentos gastos.',
                                              style: Theme.of(context).textTheme.bodySmall,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      
                      ],
                    ),
                  ),
                ),
              ),

              StreamBuilder<List<Account>>(
                stream: AccountService.instance.getAccounts(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  // Filter out removed accounts
                  final accounts = snapshot.data!.where((account) => !account.removed).toList();

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: AccountListCard(
                      accounts: accounts,
                      onAccountTap: (account) => RouteUtils.pushRoute(
                        context,
                        AccountDetailsPage(
                          account: account,
                          accountIconHeroTag: null,
                        ),
                      ),
                      onAddAccountTap: () {
                        RouteUtils.pushRoute(context, const AccountConnectionModal());
                      },
                    ),
                  );
                },
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
                          
                          // Add Income/Expense Comparison Card here
                          CardWithHeader(
                            title: t.stats.cash_flow,
                            bodyPadding: EdgeInsets.zero,
                            body: IncomeExpenseComparason(
                              startDate: dateRangeService.startDate,
                              endDate: dateRangeService.endDate,
                            ),
                            onHeaderButtonClick: () {
                              RouteUtils.pushRoute(
                                context,
                                StatsPage(
                                  dateRangeService: dateRangeService,
                                  initialIndex: 2,
                                ),
                              );
                            },
                          ),
                          // const SizedBox(height: 16),

                          // CardWithHeader(
                          //   title: t.financial_health.display,
                          //   onHeaderButtonClick: () => RouteUtils.pushRoute(
                          //       context,
                          //       StatsPage(
                          //           dateRangeService: dateRangeService,
                          //           initialIndex: 2)),
                          //   bodyPadding: const EdgeInsets.all(16),
                          //   body: StreamBuilder(
                          //     stream: FinanceHealthService().getHealthyValue(
                          //       filters: TransactionFilters(
                          //         minDate: dateRangeService.startDate,
                          //         maxDate: dateRangeService.endDate,
                          //       ),
                          //     ),
                          //     builder: (context, snapshot) {
                          //       if (!snapshot.hasData) {
                          //         return const LinearProgressIndicator();
                          //       }

                          //       final financeHealthData = snapshot.data!;

                          //       return FinanceHealthMainInfo(
                          //           financeHealthData: financeHealthData);
                          //     },
                          //   ),
                          // ),
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

    String getTooltipMessage() {
      switch (currentBalanceType) {
        case BalanceType.available:
          return 'Saldo disponível para uso imediato. Inclui as suas contas correntes e carteiras manuais, descontando os gastos no cartão de crédito. Este é o dinheiro que você pode utilizar imediatamente';
        case BalanceType.total:
          return 'Saldo disponível com reservas de emergência. Inclui a soma de todas as contas correntes mais reservas imediatas (como Poupança e Caixinhas) menos cartão de crédito. Este é o dinheiro que você possui disponível em caso de emergências.';
        case BalanceType.future:
          return 'Saldo total. Inclui conta corrente, carteira manual, caixinhas, poupanças e investimentos de longo prazo menos os saldos do cartão de crédito. Esta é a soma total de todos os seus recursos no Parsa e no Open Finance.';
      }
    }

    return GestureDetector(
      onTap: _toggleBalanceType,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPress: () {
          final RenderBox box = context.findRenderObject() as RenderBox;
          final Offset position = box.localToGlobal(Offset.zero);
          
          showMenu(
            context: context,
            position: RelativeRect.fromLTRB(
              position.dx,
              position.dy + box.size.height,
              position.dx + box.size.width,
              position.dy + box.size.height + 20,
            ),
            items: [
              PopupMenuItem(
                enabled: false,
                child: Text(
                  getTooltipMessage(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                  BalanceType.future => _buildBalanceDisplay(
                      context,
                      userData?['balance_future']?.toDouble() ?? 0.0,
                      key: ValueKey('future-balance-${currentBalanceType.index}'),
                    ),
                },
              ),
            ]
          ],
        ),
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
        return t.home.total_balance;
      case BalanceType.total:
        return 'Saldo com Reservas';
      case BalanceType.future:
        return 'Saldo Total';
    }
  }
}

