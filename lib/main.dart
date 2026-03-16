import 'dart:async'; // Added for StreamSubscription
import 'dart:io';
//import 'package:app_links/app_links.dart'; // Correctly imported package
import 'package:drift/drift.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:parsa/app/layout/navigation_sidebar.dart';
import 'package:parsa/app/layout/tabs.dart';
import 'package:parsa/app/onboarding/intro.page.dart';
import 'package:parsa/app/onboarding/onboarding.dart';
// TODO: Re-enable when intake form check is needed
// import 'package:parsa/app/onboarding/intake.dart';
import 'package:parsa/core/api/fetch_user_data_server.dart';
import 'package:parsa/core/database/services/app-data/app_data_service.dart';
import 'package:parsa/core/database/services/user-setting/user_setting_service.dart';
import 'package:parsa/core/presentation/responsive/breakpoints.dart';
import 'package:parsa/core/presentation/theme.dart';
import 'package:parsa/core/providers/app_version_provider.dart';
import 'package:parsa/core/routes/root_navigator_observer.dart';
import 'package:parsa/core/services/auth/biometrics_check_screen.dart';
import 'package:parsa/core/services/http_overrides.dart';
import 'package:parsa/core/utils/scroll_behavior_override.dart';
import 'package:parsa/core/utils/shared_preferences_async.dart';
import 'package:parsa/i18n/translations.g.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:parsa/core/services/auth/backend_auth_service.dart';
import 'package:flutter/services.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:provider/provider.dart';
import 'package:parsa/core/providers/user_data_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
//import 'package:parsa/core/services/branch/branch_config.dart';
// Keep import but don't use processing methods directly
import 'package:parsa/core/providers/link_provider.dart';
import 'package:parsa/core/routes/material_app_routes.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:parsa/core/services/branch/link_handler_service.dart';
import 'package:parsa/core/presentation/audio/audio.dart';
import 'package:parsa/core/database/services/forecast/forecast_mode_service.dart';

String apiEndpoint = '';

// Define RouteObserver
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

// Create a global variable to retain the analytics instance
FirebaseAnalytics? firebaseAnalytics;

void main() async {
  tz.initializeTimeZones();

  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await AppVersionProvider.instance.initialize();

  // Initialize sound settings
  await SoundSettings.initialize();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialized successfully");

    // Initialize and configure Firebase Analytics only in release mode
    // if (kReleaseMode) {
    firebaseAnalytics = FirebaseAnalytics.instance;
    await firebaseAnalytics?.setAnalyticsCollectionEnabled(true);
    //   print("Firebase Analytics initialized and enabled");
    // } else {
    //   print("Firebase Analytics skipped in debug mode");
    // }
  } catch (e) {
    print("Error initializing Firebase: $e");
  }

  // Set preferred orientations to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Add custom HTTP override for User-Agent
  HttpOverrides.global = CustomHttpOverrides();

  //If version is release, use the production endpoint, otherwise use the local endpoint
  apiEndpoint = kReleaseMode
      ? 'https://app.parsa-ai.com.br'
      : (dotenv.env['API_ENDPOINT'] ?? 'https://app.parsa-ai.com.br');

  // Initialize Backend Auth Service
  final backendAuthService = BackendAuthService();

  // Initialize Branch but don't process links yet
  //await BranchConfig.initialize();

  final app = MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => UserDataProvider.instance),
      ChangeNotifierProvider(
        create: (_) => backendAuthService,
      ),
      ChangeNotifierProvider(create: (_) => AppVersionProvider.instance),
      ChangeNotifierProvider(create: (_) => LinkProvider.instance),
    ],
    child: const MonekinAppEntryPoint(),
  );

  if (kReleaseMode) {
    await SentryFlutter.init(
      (options) {
        options.dsn = dotenv.env['SENTRY_DSN']!;
        options.tracesSampleRate = 1.0;
        options.profilesSampleRate = 1.0;
        options.enableAutoSessionTracking = true;
      },
      appRunner: () => runApp(app),
    );
  } else {
    runApp(app);
  }
}

final GlobalKey<TabsPageState> tabsPageKey = GlobalKey();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Sidebar key not used anymore
// final GlobalKey<NavigationSidebarState> navigationSidebarKey = GlobalKey();

class MonekinAppEntryPoint extends StatefulWidget {
  const MonekinAppEntryPoint({
    super.key,
  });

  @override
  _MonekinAppEntryPointState createState() => _MonekinAppEntryPointState();
}

class _MonekinAppEntryPointState extends State<MonekinAppEntryPoint> {
  // final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  // @override
  // void initState() {
  //   super.initState();
  //   _captureInitialLink();
  //   _setupLinkSubscription();
  // }

  // // Simplified method to just capture the initial link
  // void _captureInitialLink() async {
  //   try {
  //     final initialLink = await _appLinks.getInitialLink();
  //     if (initialLink != null) {
  //       if (mounted) {
  //         Provider.of<LinkProvider>(context, listen: false)
  //             .setPendingUri(initialLink);
  //       }
  //     }
  //   } catch (e) {
  //     print('Error capturing initial link: $e');
  //   }
  // }

  // // Add subscription for new incoming links while app is running
  // void _setupLinkSubscription() {
  //   try {
  //     _linkSubscription = _appLinks.uriLinkStream.listen((Uri uri) {
  //       if (mounted) {
  //         Provider.of<LinkProvider>(context, listen: false).setPendingUri(uri);
  //       }
  //     }, onError: (error) {
  //       print('Error receiving link updates: $error');
  //     });
  //   } catch (e) {
  //     print('Error setting up link subscription: $e');
  //   }
  // }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Print app version
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      print(
          '------------------ APP ENTRY POINT ------------------ v${AppVersionProvider.instance.fullVersion}');
      print('API_ENDPOINT: $apiEndpoint');
      print('App Version: ');
    });

    return StreamBuilder(
      stream: UserSettingService.instance.getSettings((p0) =>
          p0.settingKey.equalsValue(SettingKey.appLanguage) |
          p0.settingKey.equalsValue(SettingKey.themeMode) |
          p0.settingKey.equalsValue(SettingKey.amoledMode) |
          p0.settingKey.equalsValue(SettingKey.accentColor)),
      builder: (context, snapshot) {
        print('Finding initial user settings...');

        if (!snapshot.hasData) {
          return Container();
        }

        final userSettings = snapshot.data!;

        final lang = userSettings
            .firstWhere(
                (element) => element.settingKey == SettingKey.appLanguage)
            .settingValue;

        if (lang != null) {
          print('App language found. Setting the locale to `$lang`...');
          LocaleSettings.setLocaleRaw(lang);
        } else {
          print('App language not found. Setting the user device language...');

          LocaleSettings.useDeviceLocale();

          // Set default language if useDeviceLocale() doesn't set it
          UserSettingService.instance
              .setSetting(
                SettingKey.appLanguage,
                LocaleSettings.currentLocale.languageTag,
              )
              .then((value) => null);
        }

        LocaleSettings.setPluralResolver(
          locale: AppLocale.pt,
          cardinalResolver: (n, {zero, one, two, few, many, other}) {
            if (n == 0) return zero ?? other!;
            if (n == 1) return one ?? other!;
            return other!;
          },
          ordinalResolver: (n, {zero, one, two, few, many, other}) {
            if (n % 10 == 1 && n % 100 != 11) return one ?? other!;
            if (n % 10 == 2 && n % 100 != 12) return two ?? other!;
            if (n % 10 == 3 && n % 100 != 13) return few ?? other!;
            return other!;
          },
        );

        return TranslationProvider(
          child: StreamBuilder(
            stream: AppDataService.instance
                .getAppDataItem(AppDataKey.introSeen)
                .map((event) {
              if (event is String) {
                return event == '1'; // If event is a string, check if it's '1'
              } else if (event is bool) {
                return event; // If event is already a boolean, return it directly
              } else {
                return false; // Default case, event is neither a string nor a bool
              }
            }),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }

              return MaterialAppContainer(
                introSeen: snapshot.data!,
                accentColor: userSettings
                    .firstWhere((element) =>
                        element.settingKey == SettingKey.accentColor)
                    .settingValue!,
              );
            },
          ),
        );
      },
    );
  }
}

int refresh = 1;

class MaterialAppContainer extends StatefulWidget {
  const MaterialAppContainer({
    super.key,
    required this.accentColor,
    required this.introSeen,
  });

  final String accentColor;
  final bool introSeen;

  @override
  _MaterialAppContainerState createState() => _MaterialAppContainerState();
}

class _MaterialAppContainerState extends State<MaterialAppContainer> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    ForecastModeService.instance.initialize();
  }

  Future<void> _checkLoginStatus() async {
    final authService = Provider.of<BackendAuthService>(context, listen: false);
    bool status = await authService.checkLoginStatus();

    if (!status) {
      // If not logged in, use navigatorKey instead of context-based navigation
      if (mounted) {
        // Wait for the widget tree to be built before attempting navigation
        await Future.microtask(() {
          if (navigatorKey.currentState != null) {
            navigatorKey.currentState!.pushReplacement(
              MaterialPageRoute(builder: (context) => const IntroPage()),
            );
          }
        });
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<BackendAuthService>(context);
    Intl.defaultLocale = LocaleSettings.currentLocale.languageTag;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final ColorScheme defaultColorScheme = ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    );

    // Tell ForecastModeService the user's real theme so it can restore it
    ForecastModeService.instance.setRealTheme(
      defaultColorScheme,
      widget.accentColor,
    );

    final ThemeData defaultTheme = getThemeData(
      lightColorScheme: defaultColorScheme,
      accentColor: widget.accentColor,
    );

    return StreamBuilder<ThemeData>(
      stream: ForecastModeService.instance.themeStream,
      initialData: defaultTheme,
      builder: (context, themeSnapshot) {
        return MaterialApp(
          title: 'Parsa',
          key: ValueKey(refresh),
          debugShowCheckedModeBanner: false,
          locale: TranslationProvider.of(context).flutterLocale,
          scrollBehavior: ScrollBehaviorOverride(),
          supportedLocales: AppLocaleUtils.supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          theme: themeSnapshot.data ?? defaultTheme,
          navigatorKey: navigatorKey,
      navigatorObservers: [
        FirebaseAnalyticsObserver(
            analytics: firebaseAnalytics ?? FirebaseAnalytics.instance),
        routeObserver,
        MainLayoutNavObserver()
      ],
      onGenerateRoute: MaterialAppRoutes.onGenerateRoute,
      builder: (context, child) {
        // Check if the device is iOS
        final bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;

        return Overlay(initialEntries: [
          OverlayEntry(
            builder: (context) {
              // Conditional widget based on platform
              Widget content = Stack(
                children: [
                  Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 1500),
                        curve: Curves.easeInOutCubicEmphasized,
                        width: widget.introSeen
                            ? getNavigationSidebarWidth(context)
                            : 0,
                        color: Theme.of(context).canvasColor,
                      ),
                      if (BreakPoint.of(context).isLargerThan(BreakpointID.sm))
                        Container(
                          width: 2,
                          height: MediaQuery.of(context).size.height,
                          color: Theme.of(context).dividerColor,
                        ),
                      Expanded(child: child ?? const SizedBox.shrink()),
                    ],
                  ),
                  if (widget.introSeen)
                    // NavigationSidebar(key: navigationSidebarKey)
                    const SizedBox.shrink()
                ],
              );

              // Apply SafeArea only for Android devices
              if (!isIOS) {
                return SafeArea(
                  bottom: true,
                  child: content,
                );
              } else {
                return content;
              }
            },
          ),
        ]);
      },
      home: FutureBuilder<bool>(
        future: SharedPreferencesAsync.instance.getOnboarded(),
        builder: (context, onboardingSnapshot) {
          if (onboardingSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final bool isOnboarded = onboardingSnapshot.data ?? false;

          if (!isOnboarded) {
            return const OnboardingPage();
          }

          if (!authService.isLoggedIn) {
            return const IntroPage();
          } else {
            return BiometricsCheckScreen(
              onBiometricsVerified: () async {
                // Fetch user data from server
                await fetchUserDataAtServer();

                // Skip intake form check - go directly to TabsPage
                // TODO: Re-enable intake form check when needed
                // To restore: uncomment the block below and remove the direct navigation
                /*
                // Get user data from provider
                final userData =
                    Provider.of<UserDataProvider>(context, listen: false)
                        .userData;

                // Check if filled_questionaire is true
                if (userData != null &&
                    userData['filled_questionaire'] == true) {
                  print(
                      "USER DATA: $userData , ${userData['filled_questionaire']}");
                  // If questionnaire is filled, go directly to TabsPage
                  if (!mounted) return;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TabsPage(key: tabsPageKey)),
                  );
                  // After navigation, process pending deep links
                  WidgetsBinding.instance.addPostFrameCallback((_) async {
                    await LinkHandlerService.instance.processPendingDeepLinks();
                  });
                } else {
                  print(
                      "Questionnaire not filled or user data null, checking intake form.");
                  // If questionnaire is not filled, continue with intake form check
                  if (!mounted) return;
                  _checkIntakeFormCompletion(context);
                }
                */
                
                // Direct navigation to TabsPage (bypassing intake form)
                if (!mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TabsPage(key: tabsPageKey)),
                );
                // After navigation, process pending deep links
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  await LinkHandlerService.instance.processPendingDeepLinks();
                });
              },
            );
          }
        },
      ),
    );
      },  // StreamBuilder builder closing
    );  // StreamBuilder closing
  }

  // TODO: Re-enable when intake form check is needed
  // Helper method to check intake form completion and navigate accordingly
  // void _checkIntakeFormCompletion(BuildContext context) {
  //   // We'll use SharedPreferences to check if intake form is completed
  //   SharedPreferencesAsync.instance
  //       .getIntakeCompleted()
  //       .then((isIntakeCompleted) {
  //     if (!mounted) return; // Check mount status before navigation
  //     if (isIntakeCompleted) {
  //       // If intake is completed, go to main app (TabsPage)
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => TabsPage(key: tabsPageKey)),
  //       );
  //       // After navigation, process pending deep links
  //       WidgetsBinding.instance.addPostFrameCallback((_) async {
  //         await LinkHandlerService.instance.processPendingDeepLinks();
  //       });
  //     } else {
  //       // If intake is not completed, show IntakeForm
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => const IntakeForm()),
  //       );
  //     }
  //   });
  // }
}
