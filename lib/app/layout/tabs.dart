import 'package:flutter/material.dart';
import 'package:parsa/app/layout/lazy_indexed_stack.dart';
import 'package:parsa/core/api/fetch_user_tags_service.dart';
import 'package:parsa/core/services/notification/notification_preferences_service.dart';
import 'package:parsa/core/presentation/responsive/breakpoints.dart';
import 'package:parsa/core/routes/destinations.dart';
import 'package:parsa/core/services/notification/fcm_service.dart';
import 'package:parsa/core/services/notification/permission_service.dart';
import 'package:parsa/core/api/fetch_user_accounts.dart';
import 'package:parsa/core/api/fetch_user_transactions.dart';
import 'package:parsa/core/api/fetch_user_data_server.dart';
import 'package:parsa/core/mixins/cousin_alert_mixin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:parsa/core/services/branch/link_handler_service.dart';
import 'package:parsa/core/providers/link_provider.dart';
import 'package:parsa/core/services/auth/background_auth_service.dart';
import 'package:parsa/app/stats/stats.page.dart';
import 'package:parsa/core/models/date-utils/date_period_state.dart';
import 'package:parsa/core/routes/pending_navigation.dart';
import 'package:parsa/core/routes/navigation_delegate.dart';
import 'package:parsa/app/transactions/transactions.page.dart';
import 'package:parsa/core/presentation/widgets/transaction_filter/transaction_filters.dart';
import 'package:parsa/core/providers/user_data_provider.dart';
import 'package:parsa/core/utils/check_items_availability.dart';
import 'package:parsa/app/accounts/bank_connection_dialog.dart';
import 'package:parsa/main.dart' show firebaseAnalytics;
import 'package:parsa/core/api/post_methods/post_user_settings.dart';
import 'package:parsa/app/transactions/cousin/cousin_found_dialog.dart';
import 'package:parsa/core/utils/cousin_utils.dart';
import 'package:parsa/i18n/translations.g.dart';
import 'package:parsa/core/services/review/review_service.dart';
import 'package:parsa/core/database/services/forecast/forecast_mode_service.dart';
import 'package:parsa/core/database/services/forecast/forecast_transaction_service.dart';

// This page is the entry point of the app once the user has complete onboarding
class TabsPage extends StatefulWidget {
  const TabsPage({super.key});

  @override
  State<TabsPage> createState() => TabsPageState();

  // Static method to handle FCM reload completion
  static Future<void> handleFCMReloadComplete(BuildContext context) async {
    // Find the TabsPageState in the widget tree
    final tabsPageState = context.findAncestorStateOfType<TabsPageState>();
    if (tabsPageState != null) {
      await tabsPageState.handleFCMReloadComplete();
    }
  }
}

class TabsPageState extends State<TabsPage>
    with CousinAlertMixin, WidgetsBindingObserver {
  MainMenuDestination? selectedDestination;
  Map<String, dynamic>? userData;
  bool isLoading = true;
  bool isLoadingTransactions = true;

  // Initialization flag
  bool _isInitialized = false;
  bool isLoadingTags = true;

  // Field to store the desired initial index for StatsPage
  int _statsInitialIndex = 0;
  Key _statsPageKey = UniqueKey();

  TransactionFilters? _transactionFilters;
  Key _transactionsPageKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ReviewService.instance.appResumed();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _processPendingNav();
      await _checkConnectionDialog();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initializeData();
      _requestNotificationPermission();
      _setupDeepLinking();
      BackgroundAuthService.instance.initialize(context);
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ReviewService.instance.appPaused();
    BackgroundAuthService.instance.dispose();
    NotificationPreferencesService.instance.resetSessionFlag();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ReviewService.instance.appResumed();
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _processPendingNav();
      });
    } else if (state == AppLifecycleState.paused) {
      ReviewService.instance.appPaused();
    }
  }

  Future<void> _initializeData() async {
    try {
      print('[TABS] Initializing data...');
      // First fetch critical user info
      await _fetchUserInfoServer();

      // Then fetch all other data (accounts, transactions, tags) in parallel
      await Future.wait([refreshData(showLoading: true)]);

      // Forecasts are now fetched in dashboard.page.dart in parallel with transactions
    } catch (e) {
      if (kDebugMode) {
        print('Error during initialization: $e');
      }
    }
  }

  Future<void> refreshData({bool showLoading = true}) async {
    print('[TABS] Refreshing data...');
    if (!mounted) return;

    if (showLoading) {
      setState(() {
        isLoading = true;
        isLoadingTransactions = true;
      });
    }

    try {
      // First fetch critical user info
      await _fetchUserInfoServer();

      // Refresh accounts, transactions in parallel
      await Future.wait([_fetchUserAccounts(), _fetchUserTags()]);

      print('[TABS] Data refresh complete.');

      if (mounted && showLoading) {
        setState(() {
          isLoading = false;
          isLoadingTransactions = false;
        });
      }
    } catch (e) {
      print('--Error refreshing data: $e');
      if (mounted && showLoading) {
        setState(() {
          isLoading = false;
          isLoadingTransactions = false;
        });
      }
    }
  }

  Future<void> _processPendingNav() async {
    if (pendingNavigation != null) {
      final nav = pendingNavigation!;
      dynamic data;
      if (nav.dataFuture != null) {
        data = await nav.dataFuture;
      }
      await NavigationDelegate.instance
          .navigateToAppRoute(nav.route, id: nav.id, data: data);
      pendingNavigation = null;
    }
  }

  // Request notification permission using the FCM codelab approach
  Future<void> _requestNotificationPermission() async {
    try {
      // Check if we've requested permission before
      final prefs = await SharedPreferences.getInstance();
      final permissionRequested =
          prefs.getBool('notification_permission_requested') ?? false;

      // Always check current permissions
      final hasPermission =
          await PermissionService.instance.hasNotificationPermission();

      // If permission is already granted, just initialize FCM
      // FCM service will handle getting preferences as needed
      if (hasPermission) {
        await FCMService.instance.initialize();
        return;
      }

      // If we've never requested before, show the permission dialog
      if (!permissionRequested) {
        // Request permission with FCM (follows codelab example)
        final success =
            await FCMService.instance.requestPermissionAndInitialize();

        // Mark that we've requested permission
        await prefs.setBool('notification_permission_requested', true);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during initialization: $e');
      }
    }
  }

  Future<void> _fetchUserAccounts() async {
    setState(() {
      isLoading = true;
    });
    try {
      await fetchUserAccounts();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('--Error fetching user accounts: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchUserTags() async {
    setState(() {
      isLoadingTags = true;
    });
    try {
      await fetchUserTags(context);
      setState(() {
        isLoadingTags = false;
      });
    } catch (e) {
      print('--Error fetching user tags: $e');
      setState(() {
        isLoadingTags = false;
      });
    }
  }

  Future<void> _fetchUserInfoServer() async {
    try {
      final data = await fetchUserDataAtServer();
    } catch (e) {
      print('Error during API login: $e');
      // Handle error as needed
    }
  }

  void changePage(MainMenuDestination destination) {
    // Forecast destination: toggle forecast mode
    if (destination.id == AppMenuDestinationsID.forecast) {
      ForecastModeService.instance.toggle();
      firebaseAnalytics?.logEvent(
        name: 'forecast_mode_toggle',
        parameters: {
          'enabled':
              ForecastModeService.instance.isInForecastMode.toString(),
        },
      );
      setState(() {});
      return;
    }

    // Tapping "Início" while in forecast mode: exit forecast mode and go to Dashboard
    if (destination.id == AppMenuDestinationsID.dashboard &&
        ForecastModeService.instance.isInForecastMode) {
      ForecastModeService.instance.setForecastMode(false);
      firebaseAnalytics?.logEvent(
        name: 'forecast_mode_toggle',
        parameters: {'enabled': 'false'},
      );
      setState(() {
        selectedDestination = destination;
      });
      return;
    }

    // Track destination click in Firebase Analytics
    firebaseAnalytics?.logEvent(
      name: 'navigation_destination_click',
      parameters: {
        'destination_id': destination.id.toString(),
        'destination_label': destination.label,
        'navigation_type': 'bottom_navigation',
      },
    );

    setState(() {
      selectedDestination = destination;
    });

    // Handle ReviewService engagement tracking
    final destWidget = destination.destination;
    if (destWidget is TransactionsPage) {
      ReviewService.instance.userVisitedTransactionsPage();
    } else if (destWidget is StatsPage) {
      ReviewService.instance.userVisitedInsightsPage();
    }

    ReviewService.instance.checkAndShowReviewDialog(context);

    FocusScope.of(context).unfocus();
  }

  /// Call this to navigate to the Stats tab and set the initial subtab
  void navigateToStatsTab(int index) {
    _statsInitialIndex = index;
    _statsPageKey = UniqueKey();
    navigateToTab(2);
  }

  void navigateToTransactionsTab(TransactionFilters filters) {
    debugPrint('[TabsPage] Setting filters for Transactions tab: ' +
        filters.toString());
    final menuItems = getDestinations(context,
        shortLabels: BreakPoint.of(context).isSmallerThan(BreakpointID.xl));
    setState(() {
      _transactionFilters = filters;
      _transactionsPageKey = UniqueKey();
      selectedDestination = menuItems[1];
    });
    debugPrint('[TabsPage] Navigated to Transactions tab');
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = getDestinations(context,
        shortLabels: BreakPoint.of(context).isSmallerThan(BreakpointID.xl));

    selectedDestination ??= menuItems.elementAt(0);

    final selectedNavItemIndex = menuItems
        .indexWhere((element) => element.id == selectedDestination!.id);

    return StreamBuilder<bool>(
      stream: ForecastModeService.instance.forecastModeStream,
      initialData: ForecastModeService.instance.isInForecastMode,
      builder: (context, forecastSnapshot) {
        final isForecast = forecastSnapshot.data ?? false;

        return Scaffold(
          bottomNavigationBar: BreakPoint.of(context)
                      .isLargerThan(BreakpointID.sm) ||
                  !(0 <= selectedNavItemIndex &&
                      selectedNavItemIndex < menuItems.length)
              ? null
              : NavigationBar(
                  destinations: menuItems.map((e) {
                    if (e.id == AppMenuDestinationsID.forecast &&
                        isForecast) {
                      return NavigationDestination(
                        icon: Icon(
                          Icons.auto_awesome,
                          color: ForecastModeService.forecastAccentColor,
                        ),
                        selectedIcon: Icon(
                          Icons.auto_awesome,
                          color: ForecastModeService.forecastAccentColor,
                        ),
                        label: 'Previsões',
                      );
                    }
                    return e.toNavigationDestinationWidget();
                  }).toList(),
                  selectedIndex: selectedNavItemIndex,
                  onDestinationSelected: (e) =>
                      changePage(menuItems.elementAt(e)),
                ),
          body: Builder(builder: (context) {
            // Exclude the forecast toggle from the page stack
            final allDestinations = getAllDestinations(context,
                    shortLabels:
                        BreakPoint.of(context).isSmallerThan(BreakpointID.xl))
                .where((d) => d.id != AppMenuDestinationsID.forecast)
                .toList();

            return FadeIndexedStack(
              index: allDestinations.indexWhere(
                  (element) => element.id == selectedDestination?.id),
              duration: const Duration(milliseconds: 300),
              children: allDestinations.asMap().entries.map((entry) {
                // If this is the Stats tab, inject the initialIndex and key
                if (entry.value.destination is StatsPage) {
                  return StatsPage(
                    key: _statsPageKey,
                    initialIndex: _statsInitialIndex,
                    dateRangeService: const DatePeriodState(),
                  );
                }
                // If this is the Transactions tab, inject filters and key
                if (entry.value.destination.runtimeType.toString() ==
                    'TransactionsPage') {
                  debugPrint(
                      '[TabsPage] Building TransactionsPage with filters: ' +
                          (_transactionFilters?.toString() ?? 'null'));
                  return TransactionsPage(
                    key: _transactionsPageKey,
                    filters: _transactionFilters,
                  );
                }
                return entry.value.destination;
              }).toList(),
            );
          }),
        );
      },
    );
  }

  void _setupDeepLinking() {
    // Initialize the deep link handler
    _initializeDeepLinkHandler();

    // Schedule processing of any pending links
    _schedulePendingLinkProcessing();
  }

  // Initialize the deep link handler service
  Future<void> _initializeDeepLinkHandler() async {
    try {
      await LinkHandlerService.instance.initialize();
    } catch (e) {
      print('Error initializing deep link handler: $e');
    }
  }

  // Schedule processing of any pending deep links
  void _schedulePendingLinkProcessing() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await LinkHandlerService.instance.processPendingDeepLinks();
      LinkProvider.instance.clearPendingUri();
    });
  }

  void navigateToTab(int index) {
    if (mounted) {
      final menuItems = getDestinations(context,
          shortLabels: BreakPoint.of(context).isSmallerThan(BreakpointID.xl));

      if (index >= 0 && index < menuItems.length) {
        setState(() {
          selectedDestination = menuItems[index];
        });
      }
    }
  }

  Future<void> _checkConnectionDialog() async {
    final userData = UserDataProvider.instance.userData;
    final hasFinished = userData?['has_finished_openfinance_flow'];
    final hasItemsAvailable = userData?['has_items_available'];

    // Show connection dialog only if user hasn't finished open finance flow
    if (hasFinished == false && hasItemsAvailable == true) {
      await BankConnectionDialog.showAndHandle(context);
    }
  }

  //await BankConnectionDialog.showAndHandle(context);

  Future<void> _checkCousinFoundDialog() async {
    final userData = UserDataProvider.instance.userData;
    final hasTriggered = userData?['trigger_swipe_cards_flow'] == false;
    final hasFinished = userData?['has_finished_openfinance_flow'] == true;
    final t = Translations.of(context);

    // Only proceed if user has finished open finance flow and hasn't been triggered yet
    if (hasFinished && hasTriggered) {
      // Check if there are items in progress
      final response = await checkItemAvailability(context);
      print('checkCode: $response');

      // If items are in progress, we'll wait for the FCM "reload" signal
      // The FCM service will handle showing the uncategorized dialog after reload
      if (response == t.account.connection_errors.item_connection_in_progress) {
        if (kDebugMode) {
          print('Items in progress detected. Waiting for FCM reload signal...');
        }
        return;
      }

      // If no items in progress, check for uncategorized transactions
      final now = DateTime.now();
      final startOfTime =
          DateTime(2020, 1, 1); // Far enough back to catch all transactions
      final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);
      final cousinResult =
          await getCousinGroupSummariesForPeriod(startOfTime, endOfToday);
      final count = cousinResult.length;
      if (count > 0) {
        // Trigger the dialog and mark as triggered
        try {
          if (context.mounted) {
            await CousinFoundDialog.showAndHandle(context, cousinCount: count);
          }
        } catch (e) {
          print('Error triggering swipe cards flow: $e');
        }
      }
    }
  }

  Future<void> handleFCMReloadComplete() async {
    if (kDebugMode) {
      print('Handling FCM reload complete, checking uncategorized dialog...');
    }

    // First refresh data to get the latest transactions
    await refreshData(showLoading: false);

    // Then check if we should show the uncategorized dialog
    //await _checkCousinFoundDialog();
  }
}

class FadeIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;
  final Duration duration;
  final AlignmentGeometry alignment;
  final TextDirection? textDirection;
  final StackFit sizing;

  const FadeIndexedStack({
    super.key,
    required this.index,
    required this.children,
    this.duration = const Duration(
      milliseconds: 250,
    ),
    this.alignment = AlignmentDirectional.topStart,
    this.textDirection,
    this.sizing = StackFit.loose,
  });

  @override
  FadeIndexedStackState createState() => FadeIndexedStackState();
}

class FadeIndexedStackState extends State<FadeIndexedStack>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.duration);

  @override
  void didUpdateWidget(FadeIndexedStack oldWidget) {
    if (widget.index != oldWidget.index) {
      _controller.forward(from: 0.0);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    _controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: LazyIndexedStack(
        index: widget.index,
        alignment: widget.alignment,
        textDirection: widget.textDirection,
        sizing: widget.sizing,
        children: widget.children,
      ),
    );
  }
}
