import 'dart:async'; // Added for StreamSubscription
import 'package:app_links/app_links.dart'; // Correctly imported package
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:parsa/app/layout/navigation_sidebar.dart';
import 'package:parsa/app/layout/tabs.dart';
import 'package:parsa/core/database/services/app-data/app_data_service.dart';
import 'package:parsa/core/database/services/user-setting/user_setting_service.dart';
import 'package:parsa/core/presentation/responsive/breakpoints.dart';
import 'package:parsa/core/presentation/theme.dart';
import 'package:parsa/core/routes/root_navigator_observer.dart';
import 'package:parsa/core/services/auth/auth_service.dart';
import 'package:parsa/core/services/auth/biometrics_check_screen.dart';
import 'package:parsa/core/utils/scroll_behavior_override.dart';
import 'package:parsa/i18n/translations.g.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:parsa/core/services/auth/auth0_class.dart';
import 'package:flutter/services.dart';
import 'package:parsa/core/routes/deep_link_observer.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:provider/provider.dart';

String apiEndpoint = '';

void main() async {
  tz.initializeTimeZones();

  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  apiEndpoint = dotenv.env['API_ENDPOINT'] ?? 'https://app.parsa-ai.com.br';

  final auth0 = Auth0(
    dotenv.env['AUTH0_DOMAIN']!,
    dotenv.env['AUTH0_CLIENT_ID']!,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => Auth0Provider(auth0: auth0),
      child: const MonekinAppEntryPoint(),
    ),
  );
}

final GlobalKey<TabsPageState> tabsPageKey = GlobalKey();
final GlobalKey<NavigationSidebarState> navigationSidebarKey = GlobalKey();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MonekinAppEntryPoint extends StatefulWidget {
  const MonekinAppEntryPoint({
    super.key,
  });

  @override
  _MonekinAppEntryPointState createState() => _MonekinAppEntryPointState();
}

class _MonekinAppEntryPointState extends State<MonekinAppEntryPoint> {
  final AppLinks _appLinks = AppLinks();
  late final StreamSubscription<String?> _linkSubscription; // Changed to String

  @override
  void initState() {
    super.initState();
    _initializeAppLinks();
  }

  void _initializeAppLinks() async {
    try {
      // Handle app launch from terminated state
      final initialLink =
          await _appLinks.getInitialLink(); // Correct method name
      if (initialLink != null) {
        _handleIncomingLink(initialLink.toString());
      }

      // Listen for incoming links while the app is running
      _linkSubscription = _appLinks.stringLinkStream.listen((link) {
        // Use linkStream and String
        if (link != null && link.isNotEmpty) {
          _handleIncomingLink(link);
        }
      }, onError: (err) {
        print('Error listening to app links: $err');
      });
    } catch (e) {
      print('Failed to initialize app links: $e');
    }
  }

  void _handleIncomingLink(String link) {
    // Changed to String
    print('Received link: $link');
    // Parse the link and navigate accordingly
    // Example: Navigate to TabsPage on successful authentication callback
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TabsPage(key: tabsPageKey)),
    );
  }

  @override
  void dispose() {
    _linkSubscription.cancel();
    // _appLinks.dispose(); // Remove if dispose is not defined in AppLinks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('------------------ APP ENTRY POINT ------------------');

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
  }

  Future<void> _checkLoginStatus() async {
    final auth0Provider = Provider.of<Auth0Provider>(context, listen: false);
    bool status = await auth0Provider.checkLoginStatus();
    setState(() {
      isLoading = false;
    });
  }

@override
Widget build(BuildContext context) {
  final auth0Provider = Provider.of<Auth0Provider>(context);
  Intl.defaultLocale = LocaleSettings.currentLocale.languageTag;

  if (isLoading) {
    return const Center(child: CircularProgressIndicator());
  }

  final ColorScheme lightColorScheme = ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.light,
  );

  final ThemeData lightTheme = getThemeData(
    lightColorScheme: lightColorScheme,
    accentColor: widget.accentColor,
  );

  return MaterialApp(
    title: 'Parsa',
    key: ValueKey(refresh),
    debugShowCheckedModeBanner: false,
    locale: TranslationProvider.of(context).flutterLocale,
    scrollBehavior: ScrollBehaviorOverride(),
    supportedLocales: AppLocaleUtils.supportedLocales,
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: lightTheme,
    navigatorKey: navigatorKey,
    navigatorObservers: [
      MainLayoutNavObserver(),
      DeepLinkObserver(_handleIncomingLink)
    ],
    builder: (context, child) {
      return Overlay(initialEntries: [
        OverlayEntry(
          builder: (context) => Stack(
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
                NavigationSidebar(key: navigationSidebarKey)
            ],
          ),
        ),
      ]);
    },
      home: (auth0Provider.credentials != null
          ? TabsPage(key: tabsPageKey)
          : Auth0Service(auth0Provider: auth0Provider)),
    );
}

  void _handleIncomingLink(String link) {
    print('Received deep link: $link');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TabsPage(key: tabsPageKey)),
    );
  }
}
