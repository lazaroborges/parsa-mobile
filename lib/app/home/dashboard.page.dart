import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:parsa/app/accounts/account_connection_modal.dart';
import 'package:parsa/app/accounts/bank_connection_dialog.dart';
import 'package:parsa/app/accounts/details/account_details.dart';
import 'package:parsa/app/home/widgets/dashboard_cards/accounts_card.dart';
import 'package:parsa/app/home/widgets/dashboard_cards/budgets_card.dart';
import 'package:parsa/app/home/widgets/dashboard_cards/by_categories_card.dart';
import 'package:parsa/app/home/widgets/dashboard_cards/by_tags_card.dart';
import 'package:parsa/app/home/widgets/dashboard_cards/cash_flow_card.dart';
import 'package:parsa/app/home/widgets/dashboard_cards/credit_cards_card.dart';
import 'package:parsa/app/home/widgets/dashboard_cards/last_transactions_card.dart';
import 'package:parsa/app/home/widgets/multi_value_progress_bar.dart';
import 'package:parsa/app/transactions/uncategorized/cousin_found_dialog.dart';
import 'package:parsa/app/transactions/widgets/filtered_swipe_card_review_modal.dart';
import 'package:parsa/core/api/fetch_user_accounts.dart';
import 'package:parsa/core/api/fetch_user_budgets_service.dart';
import 'package:parsa/core/api/fetch_user_data_server.dart';
import 'package:parsa/core/api/fetch_user_tags_service.dart';
import 'package:parsa/core/api/fetch_user_transactions.dart';
import 'package:parsa/core/api/post_methods/post_user_settings.dart';
import 'package:parsa/core/database/services/account/account_service.dart';
import 'package:parsa/core/database/services/budget/budget_service.dart';
import 'package:parsa/core/database/services/category/category_service.dart';
import 'package:parsa/core/database/services/transaction/transaction_service.dart';
import 'package:parsa/core/database/services/user-setting/private_mode_service.dart';
import 'package:parsa/core/database/services/user-setting/user_setting_service.dart';
import 'package:parsa/core/models/account/account.dart';
import 'package:parsa/core/models/category/category.dart';
import 'package:parsa/core/models/dashboard/dashboard_card_config.dart';
import 'package:parsa/core/models/date-utils/date_period_state.dart';
import 'package:parsa/core/models/transaction/transaction_status.enum.dart';
import 'package:parsa/core/presentation/app_colors.dart';
import 'package:parsa/core/presentation/responsive/breakpoints.dart';
import 'package:parsa/core/presentation/responsive/responsive_row_column.dart';
import 'package:parsa/core/presentation/widgets/card_with_header.dart';
import 'package:parsa/core/presentation/widgets/dates/date_period_modal.dart';
import 'package:parsa/core/presentation/widgets/feature_announcement_modal.dart';
import 'package:parsa/core/presentation/widgets/number_ui_formatters/currency_displayer.dart';
import 'package:parsa/core/presentation/widgets/skeleton.dart';
import 'package:parsa/core/presentation/widgets/tappable.dart';
import 'package:parsa/core/presentation/widgets/transaction_filter/transaction_filters.dart';
import 'package:parsa/core/presentation/widgets/trending_value.dart';
import 'package:parsa/core/presentation/widgets/user_avatar.dart';
import 'package:parsa/core/providers/user_data_provider.dart';
import 'package:parsa/core/routes/route_utils.dart';
import 'package:parsa/core/services/dashboard_cards_service.dart';
import 'package:parsa/core/utils/cousin_utils.dart';
import 'package:parsa/core/utils/shared_preferences_async.dart' as app_prefs;
import 'package:parsa/i18n/translations.g.dart';
import 'package:parsa/main.dart'; // Import main to access routeObserver
import 'package:provider/provider.dart';

import '../../core/models/transaction/transaction_type.enum.dart';
import 'widgets/income_or_expense_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with RouteAware {
  DatePeriodState dateRangeService = const DatePeriodState();
  bool isLoading = false;
  bool isLoadingTransactions = true;
  BalanceType currentBalanceType = BalanceType.available;
  bool _isDateRangeInitialized = false;

  bool _isProgressBarLoading = true;
  double _progressBarIncome = 0.0;
  double _progressBarPureExpenses = 0.0;
  double _progressBarTotalInvestments = 0.0;
  late Future<List<DashboardCardConfig>> _cardsConfigFuture;

  @override
  void initState() {
    super.initState();
    _loadBalanceType();
    _initializePrivateMode();
    _initializeDashboard();
    _loadCardsConfig();
  }

  void _loadCardsConfig() {
    setState(() {
      _cardsConfigFuture = DashboardCardsService.instance.getCardsConfig();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to the RouteObserver
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    // Unsubscribe from the RouteObserver
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  /// Called when the top route has been popped off, and the current route shows up.
  @override
  void didPopNext() {
    _loadCardsConfig();
    _syncPreferencesWithBackend().then((_) {
      _initializeDateRangeService();
    });
  }

  Future<void> _syncPreferencesWithBackend() async {
    try {
      final prefsAsync = app_prefs.SharedPreferencesAsync.instance;
      final localStartOfWeek = await prefsAsync.getStartOfWeek();
      final localStartOfMonth = await prefsAsync.getStartOfMonth();

      // Fetch backend preferences using the fetchUserSettings function
      final backendPrefs = await PostUserSettings.fetchUserSettings();

      if (backendPrefs != null) {
        // Extract values with defaults in case they're missing
        final String? startOfWeekStr = backendPrefs['startOfWeek'];
        final backendStartOfWeek = _mapStringToStartOfWeek(startOfWeekStr);

        // Use null-aware coalescing operator to handle missing or null values
        final backendStartOfMonth = backendPrefs['startOfMonth'] as int? ?? 1;

        // Compare and update local preferences if they differ
        bool preferencesChanged = false;

        if (localStartOfWeek != backendStartOfWeek) {
          await prefsAsync.setStartOfWeek(backendStartOfWeek);
          preferencesChanged = true;
        }

        if (localStartOfMonth != backendStartOfMonth) {
          await prefsAsync.setStartOfMonth(backendStartOfMonth);
          preferencesChanged = true;
        }

        // Only trigger a re-initialization if values actually changed
        if (preferencesChanged) {
          if (mounted) {
            print(
                'Local preferences updated. Reinitializing date range service.');
            await _initializeDateRangeService();
          } else {
            print(
                'Local preferences updated but widget is not mounted, skipping UI update.');
          }
        } else {
          print('Local preferences match backend settings, no update needed.');
        }
      } else {
        print('Failed to fetch backend preferences, keeping local settings.');
      }
    } catch (e) {
      print('Error syncing preferences with backend: $e');
      // Don't let preference sync failure block the dashboard functionality
    } finally {
      // Ensure the date range service is initialized even if there was an error
      if (!_isDateRangeInitialized && mounted) {
        await _initializeDateRangeService();
      }
    }
  }

  Future<void> _initializeDashboard() async {
    try {
      // First, sync preferences with backend - this should happen early
      await _syncPreferencesWithBackend();

      // Ensure we check the announcement first
      if (mounted) {
        await FeatureAnnouncementModal.showIfNeeded(context);
      }

      // Then fetch data
      await _refreshData();
    } catch (e) {
      print('Error in dashboard initialization: $e');

      // Ensure that even if there's an error, the dashboard is still usable
      if (mounted && !_isDateRangeInitialized) {
        await _initializeDateRangeService();
      }
    } finally {
      // Always make sure loading state is cleared
      if (mounted) {
        setState(() {
          isLoading = false;
          isLoadingTransactions = false;
        });
      }
    }
  }

  Future<void> _initializeDateRangeService() async {
    final prefsAsync = app_prefs.SharedPreferencesAsync.instance;
    final startDay = await prefsAsync.getStartOfMonth();
    final startWeek = await prefsAsync.getStartOfWeek();

    bool needsUpdate = !_isDateRangeInitialized ||
        dateRangeService.startOfMonthDay != startDay ||
        dateRangeService.startOfWeek != startWeek;

    if (mounted && needsUpdate) {
      setState(() {
        dateRangeService = dateRangeService.copyWith(
          startOfMonthDay: startDay,
          startOfWeek: startWeek,
        );
        _isDateRangeInitialized = true;
      });
    }
  }

  Future<void> _refreshData() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      isLoadingTransactions = true;
    });

    try {
      // First fetch user data
      unawaited(fetchUserDataAtServer());

      // Then fetch accounts and tags before transactions and budget
      await Future.wait([
        fetchUserAccounts(),
        fetchUserTags(context),
      ]);

      // Finally fetch transactions and budgets
      await Future.wait([
        fetchUserTransactions(null),
        fetchUserBudgets(context),
      ]);

      // HACK: Short delay to allow database writes to settle before reading.
      // This is to address a race condition on initial login where the progress
      // bar data is queried before transaction processing is complete.
      await Future.delayed(const Duration(milliseconds: 2000));

      if (mounted) {
        await _updateProgressBarData();
      }
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

  Future<void> _updateProgressBarData() async {
    if (!mounted || !_isDateRangeInitialized) return;

    setState(() {
      _isProgressBarLoading = true;
    });

    try {
      final incomeStream = AccountService.instance.getAccountsBalance(
        filters: TransactionFilters(
          minDate: dateRangeService.startDate,
          maxDate: dateRangeService.endDate,
          transactionTypes: [TransactionType.I],
        ),
      );

      final expenseStream = AccountService.instance.getAccountsBalance(
        filters: TransactionFilters(
          minDate: dateRangeService.startDate,
          maxDate: dateRangeService.endDate,
          transactionTypes: [TransactionType.E],
        ),
      );

      final investmentCategoryStream =
          CategoryService.instance.getCategoryByName('Investimentos');

      final results = await Future.wait([
        incomeStream.first,
        expenseStream.first,
        investmentCategoryStream.first,
      ]);

      final income = results[0] as double;
      final totalExpenses = results[1] as double;
      final investmentCategory = results[2] as Category?;

      double consideredInvestments = 0.0;
      double notConsideredInvestment = 0.0;

      if (investmentCategory != null) {
        // Considered: what counts for stats.
        final consideredStatus =
            TransactionStatus.getStatusThatCountsForStats(null);

        // Disconsidered: what DOES NOT count for stats.
        final notConsideredStatus = [
          TransactionStatus.pending,
          TransactionStatus.voided,
          TransactionStatus.notconsidered,
        ];

        // We use TransactionService directly to avoid the filtering in getAccountsBalance
        final consideredStream = TransactionService.instance
            .countTransactions(
                predicate: TransactionFilters(
                    minDate: dateRangeService.startDate,
                    maxDate: dateRangeService.endDate,
                    categories: [investmentCategory.id],
                    status: consideredStatus))
            .map((event) => event.valueSum);

        final notConsideredStream = TransactionService.instance
            .countTransactions(
                predicate: TransactionFilters(
                    minDate: dateRangeService.startDate,
                    maxDate: dateRangeService.endDate,
                    categories: [investmentCategory.id],
                    status: notConsideredStatus))
            .map((event) => event.valueSum);

        final investmentResults = await Future.wait(
            [consideredStream.first, notConsideredStream.first]);

        consideredInvestments = investmentResults[0];
        notConsideredInvestment = investmentResults[1];
      }

      final totalInvestments =
          consideredInvestments.abs() + notConsideredInvestment.abs();
      final pureExpenses = totalExpenses.abs() - consideredInvestments.abs();

      if (mounted) {
        setState(() {
          _progressBarIncome = income.abs();
          _progressBarPureExpenses = pureExpenses;
          _progressBarTotalInvestments = totalInvestments;
          _isProgressBarLoading = false;
        });
      }
    } catch (e) {
      print('Error updating progress bar data: $e');
      if (mounted) {
        setState(() {
          _isProgressBarLoading = false;
        });
      }
    }
  }

  Future<void> _loadBalanceType() async {
    final prefsAsync = app_prefs.SharedPreferencesAsync.instance;
    final balanceTypeStr = await prefsAsync.getBalanceType();

    // Convert string to enum
    switch (balanceTypeStr) {
      case 'available':
        currentBalanceType = BalanceType.available;
        break;
      case 'total':
        currentBalanceType = BalanceType.total;
        break;
      case 'future':
        currentBalanceType = BalanceType.future;
        break;
      default:
        currentBalanceType = BalanceType.available;
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _initializePrivateMode() async {
    await PrivateModeService.instance.initializePrivateMode();
  }

  void _toggleBalanceType() {
    setState(() {
      currentBalanceType = BalanceType
          .values[(currentBalanceType.index + 1) % BalanceType.values.length];

      // Save the balance type preference
      app_prefs.SharedPreferencesAsync.instance
          .setBalanceType(currentBalanceType.name);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    if (!_isDateRangeInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
        appBar: EmptyAppBar(color: AppColors.of(context).light),
        drawer: null,
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(children: [
              DefaultTextStyle.merge(
                style: TextStyle(
                    color: Theme.of(context).appBarTheme.foregroundColor),
                child: Card(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Tappable(
                              onTap: () {},
                              bgColor: Colors.transparent,
                              borderRadius: 12,
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Row(
                                  children: [
                                    if (BreakPoint.of(context)
                                        .isSmallerThan(BreakpointID.md)) ...[
                                      if (context
                                                  .watch<UserDataProvider>()
                                                  .userData !=
                                              null &&
                                          context
                                                  .watch<UserDataProvider>()
                                                  .userData!['avatar_url'] !=
                                              null)
                                        CircleAvatar(
                                          backgroundImage: NetworkImage(context
                                              .watch<UserDataProvider>()
                                              .userData!['avatar_url']),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                .getSetting(
                                                    SettingKey.userName),
                                            builder: (context, snapshot) {
                                              final userData = context
                                                  .watch<UserDataProvider>()
                                                  .userData;
                                              final isSubscriber = userData !=
                                                      null &&
                                                  userData['is_subscriber'] ==
                                                      true;

                                              if (userData != null &&
                                                  userData['first_name'] !=
                                                      null) {
                                                final firstName =
                                                    userData['first_name']
                                                        .toString();

                                                return Row(
                                                  children: [
                                                    Text(
                                                      firstName,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleSmall!
                                                          .copyWith(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 18,
                                                          ),
                                                    ),
                                                    if (isSubscriber) ...[
                                                      const SizedBox(width: 8),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 8,
                                                                vertical: 2),
                                                        decoration:
                                                            BoxDecoration(
                                                          gradient:
                                                              const LinearGradient(
                                                            colors: [
                                                              const Color(
                                                                  0xFF1c64f2),
                                                              const Color(
                                                                  0xFF1724c9),
                                                            ],
                                                            begin: Alignment
                                                                .topLeft,
                                                            end: Alignment
                                                                .bottomRight,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      0.2),
                                                              blurRadius: 2,
                                                              offset:
                                                                  const Offset(
                                                                      0, 1),
                                                            ),
                                                          ],
                                                        ),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Icon(
                                                              Icons.star,
                                                              size: 12,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            const SizedBox(
                                                                width: 2),
                                                            Text(
                                                              "PREMIUM",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                letterSpacing:
                                                                    0.5,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                );
                                              }

                                              if (!snapshot.hasData) {
                                                return const Skeleton(
                                                    width: 70, height: 12);
                                              }

                                              return Row(
                                                children: [
                                                  Text(
                                                    snapshot.data!,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleSmall!
                                                        .copyWith(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 18,
                                                        ),
                                                  ),
                                                  if (isSubscriber) ...[
                                                    const SizedBox(width: 8),
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 2),
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            const LinearGradient(
                                                          colors: [
                                                            const Color(
                                                                0xFF1c64f2),
                                                            const Color(
                                                                0xFF1724c9),
                                                          ],
                                                          begin:
                                                              Alignment.topLeft,
                                                          end: Alignment
                                                              .bottomRight,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.2),
                                                            blurRadius: 2,
                                                            offset:
                                                                const Offset(
                                                                    0, 1),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            Icons.star,
                                                            size: 12,
                                                            color: Colors.white,
                                                          ),
                                                          const SizedBox(
                                                              width: 2),
                                                          Text(
                                                            "PREMIUM",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              letterSpacing:
                                                                  0.5,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              );
                                            }),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                StreamBuilder(
                                  stream: PrivateModeService
                                      .instance.privateModeStream,
                                  initialData: false,
                                  builder: (context, snapshot) {
                                    final isPrivate = snapshot.data ?? false;
                                    return IconButton(
                                      icon: Icon(
                                        isPrivate
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        size: 20,
                                        color: Colors.grey[500],
                                      ),
                                      style: IconButton.styleFrom(
                                        padding: const EdgeInsets.all(8),
                                      ),
                                      onPressed: () {
                                        PrivateModeService.instance
                                            .setPrivateMode(!isPrivate);
                                      },
                                    );
                                  },
                                ),
                                const SizedBox(width: 4),
                                ActionChip(
                                  label:
                                      Text(dateRangeService.getText(context)),
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
                                    if (!_isDateRangeInitialized) return;

                                    openDatePeriodModal(
                                      context,
                                      DatePeriodModal(
                                        initialDatePeriod:
                                            dateRangeService.datePeriod,
                                      ),
                                    ).then((value) {
                                      if (value == null) return;
                                      setState(() {
                                        dateRangeService =
                                            dateRangeService.copyWith(
                                          periodModifier: 0,
                                          datePeriod: value,
                                          startOfMonthDay:
                                              dateRangeService.startOfMonthDay,
                                          startOfWeek:
                                              dateRangeService.startOfWeek,
                                        );
                                      });
                                      _updateProgressBarData();
                                    });
                                  },
                                ),
                              ],
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
                                    context, accounts, AccountService.instance),
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
                        const SizedBox(height: 16),
                        if (true) ...[
                          if (_isProgressBarLoading)
                            const LinearProgressIndicator()
                          else
                            AnimatedExpenseProgressBar(
                              key: ValueKey(
                                  '${dateRangeService.startDate}-${dateRangeService.endDate}'),
                              income: _progressBarIncome,
                              pureExpenses: _progressBarPureExpenses,
                              totalInvestments: _progressBarTotalInvestments,
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              if (kDebugMode) ...[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Column(
                    children: [
                      // Cousin Found Dialog Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.bug_report),
                          label:
                              const Text('DEBUG: Trigger Cousin Found Dialog'),
                          onPressed: () async {
                            // Set firstTriggerSwipeCards to false for testing
                            await app_prefs.SharedPreferencesAsync.instance
                                .setFirstTriggerSwipeCards(false);

                            // Get actual cousin count using all past transactions
                            final now = DateTime.now();
                            final startOfTime = DateTime(1900, 1,
                                1); // Far enough back to catch all transactions
                            final endOfToday = DateTime(
                                now.year, now.month, now.day, 23, 59, 59);
                            final cousinResult = await getCousinGroupsForPeriod(
                                startOfTime, endOfToday);
                            final actualCount = cousinResult.totalGroups;

                            await CousinFoundDialog.showAndHandle(
                              context,
                              cousinCount:
                                  actualCount, // Use actual count instead of mock
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange,
                            side: const BorderSide(color: Colors.orange),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Bank Connection Dialog Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.account_balance),
                          label:
                              const Text('DEBUG: Open Bank Connection Dialog'),
                          onPressed: () {
                            BankConnectionDialog.showAndHandle(context);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            side: const BorderSide(color: Colors.blue),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              FutureBuilder<List<DashboardCardConfig>>(
                future: _cardsConfigFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      !snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final cardsConfig = snapshot.data!;

                  final cardWidgets =
                      cardsConfig.where((card) => card.enabled).map((card) {
                    return _buildCardWidget(card.key);
                  }).toList();

                  return ResponsiveRowColumn(
                    direction:
                        BreakPoint.of(context).isLargerThan(BreakpointID.md)
                            ? Axis.horizontal
                            : Axis.vertical,
                    rowCrossAxisAlignment: CrossAxisAlignment.start,
                    columnSpacing: 8,
                    rowSpacing: 8,
                    children: cardWidgets
                        .map((e) => ResponsiveRowColumnItem(
                              rowFit: FlexFit.tight,
                              child: e,
                            ))
                        .toList(),
                  );
                },
              ),
            ]),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat);
  }

  Widget _buildCardWidget(DashboardCardKey key) {
    switch (key) {
      case DashboardCardKey.accounts:
        return const AccountsCard();
      case DashboardCardKey.creditCards:
        return const CreditCardsCard();
      case DashboardCardKey.lastTransactions:
        return Column(
          children: [
            const LastTransactionsCard(),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 6, 32, 0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: FilledButton.icon(
                  icon: const Icon(Icons.swipe),
                  label: const Text(
                    'Rever suas transações agrupadas',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onPressed: isLoadingTransactions
                      ? null
                      : () async {
                          showDialog(
                            context: context,
                            barrierDismissible: true,
                            barrierColor: Colors.transparent,
                            builder: (context) =>
                                const FilteredSwipeCardReviewModal(),
                          );
                        },
                  style: isLoadingTransactions
                      ? FilledButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.grey[600],
                        )
                      : null,
                ),
              ),
            ),
          ],
        );
      case DashboardCardKey.byCategories:
        return ByCategoriesCard(dateRangeService: dateRangeService);
      case DashboardCardKey.cashFlow:
        return CashFlowCard(dateRangeService: dateRangeService);
      case DashboardCardKey.byTags:
        return ByTagsCard(dateRangeService: dateRangeService);
      case DashboardCardKey.budgets:
        return const BudgetsCard();
    }
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
          return 'Saldo disponível para uso imediato. Inclui a soma de todas as contas correntes e carteiras manuais.';
        case BalanceType.total:
          return 'Saldo disponível com reservas de emergência. Inclui a soma de todas as contas correntes mais reservas imediatas (como Poupança e Caixinhas) menos cartão de crédito. Este é o dinheiro que você possui disponível em caso de emergências.';
        case BalanceType.future:
          return 'Saldo total. Inclui conta corrente, carteira manual, caixinhas, poupanças e investimentos de longo prazo menos os saldos do cartão de crédito. Esta é a soma total de todos os seus recursos no Parsa e no Open Finance.';
      }
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _toggleBalanceType,
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
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          // Detect swipe direction
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! > 0) {
              // Swipe right - move to previous balance type
              setState(() {
                int newIndex =
                    (currentBalanceType.index - 1) % BalanceType.values.length;
                if (newIndex < 0) newIndex = BalanceType.values.length - 1;
                currentBalanceType = BalanceType.values[newIndex];

                // Save the balance type preference
                app_prefs.SharedPreferencesAsync.instance
                    .setBalanceType(currentBalanceType.name);
              });
            } else if (details.primaryVelocity! < 0) {
              // Swipe left - move to next balance type
              setState(() {
                currentBalanceType = BalanceType.values[
                    (currentBalanceType.index + 1) % BalanceType.values.length];

                app_prefs.SharedPreferencesAsync.instance
                    .setBalanceType(currentBalanceType.name);
              });
            }
          }
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
                      key: ValueKey(
                          'available-balance-${currentBalanceType.index}'),
                    ),
                  BalanceType.total => _buildBalanceDisplay(
                      context,
                      userData?['balance_total']?.toDouble() ?? 0.0,
                      key:
                          ValueKey('total-balance-${currentBalanceType.index}'),
                    ),
                  BalanceType.future => _buildBalanceDisplay(
                      context,
                      userData?['balance_future']?.toDouble() ?? 0.0,
                      key: ValueKey(
                          'future-balance-${currentBalanceType.index}'),
                    ),
                },
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceDisplay(BuildContext context, double balance,
      {Key? key}) {
    double screenWidth = MediaQuery.of(context).size.width;
    double widthMultiplier = 0.45;

    return Container(
      key: key,
      width: screenWidth * widthMultiplier,
      height: 56,
      alignment: Alignment.centerLeft,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 48,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: CurrencyDisplayer(
                amountToConvert: balance,
                integerStyle: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.titleLarge!.color,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < BalanceType.values.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == currentBalanceType.index
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).disabledColor.withOpacity(0.4),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
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
  final Widget child;

  const DashboardTransactionList({Key? key, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class AnimatedExpenseProgressBar extends StatelessWidget {
  final double income;
  final double pureExpenses;
  final double totalInvestments;

  const AnimatedExpenseProgressBar({
    super.key,
    required this.income,
    required this.pureExpenses,
    required this.totalInvestments,
  });

  @override
  Widget build(BuildContext context) {
    print("--- AnimatedExpenseProgressBar BUILD ---");
    print(
        "income: $income, pureExpenses: $pureExpenses, totalInvestments: $totalInvestments");
    // Use a Tween from 0.0 to 1.0 to act as a multiplier for the animation progress.
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeInOut,
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, animationValue, child) {
        // The animated values are the final values multiplied by the animation progress (0.0 to 1.0)
        final animatedPureExpenses = pureExpenses * animationValue;
        final animatedTotalInvestments = totalInvestments * animationValue;

        // The values to pass to the progress bar widget
        final animatedValues = [
          ProgressBarValue(amount: animatedPureExpenses, color: Colors.red),
          ProgressBarValue(
              amount: animatedTotalInvestments, color: Colors.blue),
        ];

        // Calculate percentages for the text labels based on the animated values
        final animatedSpentPercentage =
            income > 0 ? animatedPureExpenses / income : 0.0;
        final animatedInvestmentPercentage =
            income > 0 ? animatedTotalInvestments / income : 0.0;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
          width: double.infinity,
          child: Column(
            children: [
              MultiValueProgressBar(
                total: income, // The bar's total is the income
                values: animatedValues,
              ),
              const SizedBox(height: 2),
              Text(
                '${(animatedSpentPercentage * 100).toStringAsFixed(1)}% da renda gasta.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 2),
              Text(
                '${(animatedInvestmentPercentage * 100).toStringAsFixed(1)}% da renda investida.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        );
      },
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

// Function to map string to integer for startOfWeek
int _mapStringToStartOfWeek(String? startOfWeek) {
  // Handle null or empty values gracefully
  if (startOfWeek == null || startOfWeek.isEmpty) {
    print('Empty startOfWeek value. Defaulting to Sunday (7).');
    return 7; // Default to Sunday
  }

  switch (startOfWeek.toLowerCase().trim()) {
    case 'monday':
      return 1; // DateTime.monday;
    case 'saturday':
      return 6; // DateTime.saturday;
    case 'sunday':
      return 7; // DateTime.sunday;
    // Add string number handling
    case '1':
      return 1;
    case '6':
      return 6;
    case '7':
      return 7;
    default:
      print(
          'Invalid startOfWeek value: $startOfWeek. Defaulting to Sunday (7).');
      return 7; // Default to Sunday
  }
}
