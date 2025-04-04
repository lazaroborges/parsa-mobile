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
import 'package:parsa/core/routes/navigation_delegate.dart';

// This page is the entry point of the app once the user has complete onboarding
class TabsPage extends StatefulWidget {
  const TabsPage({super.key});

  @override
  State<TabsPage> createState() => TabsPageState();
}

class TabsPageState extends State<TabsPage> with CousinAlertMixin {
  MainMenuDestination? selectedDestination;
  Map<String, dynamic>? userData;
  bool isLoading = true;
  bool isLoadingTransactions = true;

  // Initialization flag
  bool _isInitialized = false;
  bool isLoadingTags = true;

  @override
  void initState() {
    super.initState();
    print('loaded init state');
    // Remove the _initializeData call from here
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      // Remove the context setting since we no longer use it
      _initializeData();
      _requestNotificationPermission();
      _initDeepLinking();
      _isInitialized = true; // Ensure this runs only once
    }
  }

  // Request notification permission when the dashboard is opened
  Future<void> _requestNotificationPermission() async {
    final prefs = await SharedPreferences.getInstance();
    final permissionRequested =
        prefs.getBool('notification_permission_requested') ?? false;

    // Only proceed if we haven't requested permission before
    if (!permissionRequested) {
      // Request permission using the permission service
      final permissionGranted =
          await PermissionService.instance.requestNotificationPermission();

      if (permissionGranted) {
        // If permission granted, initialize FCM
        await FCMService.instance.initialize();

        // Enable notifications by default for new installs if permission is granted
        await NotificationPreferencesService.instance.updatePreferences(
          budgetsEnabled: true,
          generalEnabled: true,
        );

        // Store that user has granted permission
        await prefs.setBool('notification_permission_requested', true);
      } else {
        // If permission denied, still store that we requested it
        await prefs.setBool('notification_permission_requested', true);

        // Make sure notifications are disabled in backend
        await NotificationPreferencesService.instance.updatePreferences(
          budgetsEnabled: false,
          generalEnabled: false,
        );
      }
    } else {
      // Just initialize FCM - it will check backend preferences internally
      // await FCMService.instance.initialize();
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

  Future<void> _fetchAndSyncTransactions() async {
    setState(() {
      isLoadingTransactions = true;
    });
    try {
      await fetchUserTransactions(null);
      setState(() {
        isLoadingTransactions = false;
      });
    } catch (e) {
      print('--Error fetching user transactions: $e');
      setState(() {
        isLoadingTransactions = false;
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
    navigationSidebarKey.currentState?.setSelectedDestination(destination);

    setState(() {
      selectedDestination = destination;
    });

    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    // Remove the context update since we no longer use it

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
          children: allDestinations.map((e) => e.destination).toList(),
        );
      }),
    );
  }

  // Separate method for initializing deep linking to improve code organization
  void _initDeepLinking() {
    // Delay initialization until after the initial data loading and UI building is complete
    Future.delayed(Duration(milliseconds: 1000), () {
      if (!mounted) return;

      print('Initializing deep link handler service...');

      // Initialize the link handler service which sets up the Branch SDK listener
      LinkHandlerService.instance.initialize().then((_) {
        if (!mounted) return;

        // Process any pending deep links that might have been captured during startup
        print('Processing any pending deep links...');
        LinkHandlerService.instance.processPendingDeepLinks(onComplete: () {
          // After navigation is complete, clear the pending URI
          Future.delayed(Duration(milliseconds: 300), () {
            if (mounted) {
              LinkHandlerService.instance.clearPendingUri();
            }
          });
        });
      });
    });
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
