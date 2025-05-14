import 'package:flutter/material.dart';
import 'package:parsa/app/layout/lazy_indexed_stack.dart';
import 'package:parsa/core/api/fetch_user_tags_service.dart';
import 'package:parsa/core/services/notification/notification_preferences_service.dart';
import 'package:parsa/core/presentation/responsive/breakpoints.dart';
import 'package:parsa/core/routes/destinations.dart';
import 'package:parsa/core/services/notification/fcm_service.dart';
import 'package:parsa/core/services/notification/permission_service.dart';
import 'package:parsa/main.dart';
import 'package:parsa/core/api/fetch_user_accounts.dart';
import 'package:parsa/core/api/fetch_user_transactions.dart';
import 'package:parsa/core/api/fetch_user_data_server.dart';
import 'package:parsa/core/mixins/cousin_alert_mixin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:parsa/core/services/branch/link_handler_service.dart';
import 'package:parsa/core/providers/link_provider.dart';
import 'package:provider/provider.dart';
import 'package:parsa/core/services/auth/background_auth_service.dart';
import 'package:parsa/app/stats/stats.page.dart';
import 'package:parsa/core/models/date-utils/date_period_state.dart';
import 'package:parsa/core/routes/pending_navigation.dart';
import 'package:parsa/core/routes/navigation_delegate.dart';
import 'package:parsa/app/transactions/transactions.page.dart';
import 'package:parsa/core/presentation/widgets/transaction_filter/transaction_filters.dart';
import 'package:parsa/core/providers/bank_callback_provider.dart';
import 'package:parsa/core/utils/check_items_availability.dart';
import 'package:parsa/app/accounts/bank_callback_dialog.dart';

// This page is the entry point of the app once the user has complete onboarding
class TabsPage extends StatefulWidget {
  const TabsPage({super.key});

  @override
  State<TabsPage> createState() => TabsPageState();
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _processPendingNav();
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
    BackgroundAuthService.instance.dispose();
    NotificationPreferencesService.instance.resetSessionFlag();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _processPendingNav();
      });
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
        print('Error handling notification permissions: $e');
      }
    }
  }

  Future<void> _initializeData() async {
    try {
      // First fetch critical user info
      await _fetchUserInfoServer();

      // Then fetch accounts and tags in parallel
      await Future.wait([
        _fetchUserAccounts(),
        _fetchUserTags(),
      ], eagerError: true);
    } catch (e) {
      if (kDebugMode) {
        print('Error during initialization: $e');
      }
      // Handle initialization error appropriately
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

  // Public method to refresh both transactions and accounts from anywhere in the app
  // This can be called when a notification with action=reload is received
  Future<void> refreshData({bool showLoading = true}) async {
    if (!mounted) return;

    if (showLoading) {
      setState(() {
        isLoading = true;
        isLoadingTransactions = true;
      });
    }

    try {
      // Refresh both accounts and transactions in parallel
      await Future.wait([
        _fetchUserAccounts(),
        fetchUserTransactions(null),
      ]);

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
    navigationSidebarKey.currentState?.setSelectedDestination(destination);

    setState(() {
      selectedDestination = destination;
    });

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

    return Scaffold(
      bottomNavigationBar: BreakPoint.of(context)
                  .isLargerThan(BreakpointID.sm) ||
              !(0 <= selectedNavItemIndex &&
                  selectedNavItemIndex < menuItems.length)
          ? null
          : NavigationBar(
              destinations: menuItems
                  .map((e) => e.toNavigationDestinationWidget())
                  .toList(),
              selectedIndex: selectedNavItemIndex,
              onDestinationSelected: (e) => changePage(menuItems.elementAt(e)),
            ),
      body: Builder(builder: (context) {
        final allDestinations = getAllDestinations(context,
            shortLabels: BreakPoint.of(context).isSmallerThan(BreakpointID.xl));

        return FadeIndexedStack(
          index: allDestinations
              .indexWhere((element) => element.id == selectedDestination?.id),
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
              debugPrint('[TabsPage] Building TransactionsPage with filters: ' +
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
  }

  // Set up deep linking with authentication check
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

  // Called by LinkHandlerService when a bank callback is detected
  Future<void> checkBankCallbackFlag() async {
    if (kDebugMode) {
      print('🏦 TabsPage: checkBankCallbackFlag() called');
    }

    // Check if the widget is still mounted before proceeding
    if (!mounted) {
      if (kDebugMode) {
        print('🏦 TabsPage: Widget not mounted, skipping callback handling');
      }
      BankCallbackProvider.instance.reset();
      return;
    }

    final bankCallbackProvider =
        Provider.of<BankCallbackProvider>(context, listen: false);
    if (!bankCallbackProvider.bankCallbackReceived) {
      return;
    }

    try {
      // Check if user can connect more accounts
      final errorMessage = await checkItemAvailability(context);
      final canConnectMoreAccounts = errorMessage == null;

      if (kDebugMode) {
        print(
            '🏦 TabsPage: Can connect more accounts: $canConnectMoreAccounts');
        if (errorMessage != null) {
          print('🏦 TabsPage: Error message: $errorMessage');
        }
      }

      // Only show the dialog if the user can connect more accounts and the widget is still mounted
      if (canConnectMoreAccounts && mounted) {
        // Use Future.microtask to avoid build-phase errors
        Future.microtask(() async {
          if (mounted) {
            await BankCallbackDialog.showAndHandle(context);
          }
        });
      } else if (mounted) {
        // Show error message if the user cannot connect more accounts
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(errorMessage ?? 'Erro ao verificar disponibilidade')),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('🏦 TabsPage: Error during bank callback check: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao verificar disponibilidade')),
        );
      }
    } finally {
      // Always reset the flag regardless of the result
      bankCallbackProvider.reset();
    }
  }

  // Schedule processing of any pending deep links
  void _schedulePendingLinkProcessing() {
    // Schedule processing of pending links after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LinkHandlerService.instance.processPendingDeepLinks();

      // Clear any URI data from the provider directly
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
