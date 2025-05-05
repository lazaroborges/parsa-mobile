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
import 'package:parsa/core/services/auth/auth0_class.dart';
import 'package:parsa/core/services/auth/background_auth_service.dart';
import 'package:parsa/app/stats/stats.page.dart';
import 'package:parsa/core/models/date-utils/date_period_state.dart';
import 'package:parsa/core/routes/pending_navigation.dart';
import 'package:parsa/core/routes/navigation_delegate.dart';
import 'package:parsa/core/presentation/widgets/transaction_filter/transaction_filters.dart';
import 'package:parsa/app/transactions/transactions.page.dart';

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

  // Create a static global key for access from outside
  static final GlobalKey<TabsPageState> globalKey = GlobalKey<TabsPageState>();

  // Field to store the desired initial index for StatsPage
  int _statsInitialIndex = 0;
  Key _statsPageKey = UniqueKey();
  TransactionFilters? _statsFilters;
  TransactionFilters? _transactionsFilters;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Defer navigation until after first frame
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
    // Dispose of background authentication service
    BackgroundAuthService.instance.dispose();
    // Reset notification preferences session flag for next app start
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
      await NavigationDelegate.instance.navigateToAppRoute(nav.route,
          id: nav.id, data: data, queryParams: nav.queryParams);
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

  /// Call this to navigate to the Stats tab and set the initial subtab and filters
  void navigateToStatsTabWithFilters(
      {int index = 0, TransactionFilters? filters}) {
    _statsInitialIndex = index;
    _statsFilters = filters;
    _statsPageKey = UniqueKey(); // Force StatsPage to rebuild
    navigateToTab(2); // Assuming Stats is tab index 2
  }

  /// Call this to navigate to the Transactions tab and set filters
  void navigateToTransactionsTabWithFilters({TransactionFilters? filters}) {
    _transactionsFilters = filters;
    navigateToTab(1); // Assuming Transactions is tab index 1
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
            // If this is the Transactions tab, inject filters
            if (entry.value.destination.runtimeType.toString() ==
                'TransactionsPage') {
              return TransactionsPage(
                filters: _transactionsFilters,
              );
            }
            // If this is the Stats tab, inject the initialIndex, filters, and key
            if (entry.value.destination is StatsPage) {
              return StatsPage(
                key: _statsPageKey,
                initialIndex: _statsInitialIndex,
                filters: _statsFilters ?? const TransactionFilters(),
                dateRangeService: const DatePeriodState(),
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

  // Process any pending links with authentication check
  void _schedulePendingLinkProcessing() {
    // Slightly delay to ensure app is fully loaded
    Future.delayed(Duration(milliseconds: 500), () {
      if (!mounted) return;

      // Check for pending URI in provider
      final linkProvider = Provider.of<LinkProvider>(context, listen: false);
      final pendingUri = linkProvider.pendingUri;

      if (pendingUri != null) {
        // Check authentication before processing
        final auth0Provider =
            Provider.of<Auth0Provider>(context, listen: false);

        if (auth0Provider.credentials != null) {
          // User is authenticated, process the link
          LinkHandlerService.instance.processPendingDeepLinks(onComplete: () {
            // Clear the pending URI after successful processing
            Future.delayed(Duration(milliseconds: 300), () {
              if (mounted) {
                LinkHandlerService.instance.clearPendingUri();
              }
            });
          });
        } else {
          print(
              'Auth credentials not available, deep link will be processed after login');
        }
      }
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
