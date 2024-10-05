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
import 'package:parsa/core/utils/scroll_behavior_override.dart';
import 'package:parsa/i18n/translations.g.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:parsa/core/services/auth/auth0_class.dart';
import 'package:parsa/core/services/auth/auth_methods.dart';
import 'package:local_auth/local_auth.dart' as local_auth;
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final auth0 = Auth0(
    dotenv.env['AUTH0_DOMAIN']!,
    dotenv.env['AUTH0_CLIENT_ID']!,
  );

  runApp(Auth0Provider(
    auth0: auth0,
    child: const MonekinAppEntryPoint(),
  ));
}

final GlobalKey<TabsPageState> tabsPageKey = GlobalKey();
final GlobalKey<NavigationSidebarState> navigationSidebarKey = GlobalKey();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MonekinAppEntryPoint extends StatelessWidget {
  const MonekinAppEntryPoint({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    print('------------------ APP ENTRY POINT ------------------');
    globalAppContext = context;

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
            print(
                'App language not found. Setting the user device language...');

            LocaleSettings.useDeviceLocale();

            // We have nothing to worry here since the useDeviceLocale() func will set the default lang (english in our case) if
            // the user is using a non-supported language in his device

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
                    return event ==
                        '1'; // If event is a string, check if it's '1'
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
                }),
          );
        });
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
  bool isLoggedIn = false;
  bool isLoading = true;

  final local_auth.LocalAuthentication auth = local_auth.LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // Existing _checkLoginStatus method
  Future<void> _checkLoginStatus() async {
    bool status = await AuthMethods.checkLoginStatus(context);
    print('STATUS: $status ${status.runtimeType}');
    if (status) {
      bool biometricSuccess = true;
      // await _authenticateWithBiometrics();
      if (biometricSuccess) {
        setState(() {
          isLoggedIn = true;
          isLoading = false;
        });
      } else {
        // Show an alert dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Authentication Failed'),
            content: Text('Unable to authenticate using biometrics.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );

        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoggedIn = status;
        isLoading = false;
      });
    }
  }

  Future<bool> _authenticateWithBiometrics() async {
    bool canCheckBiometrics = await auth.canCheckBiometrics;
    bool isDeviceSupported = await auth.isDeviceSupported();

    if (!canCheckBiometrics || !isDeviceSupported) {
      return false;
    }

    try {
      bool authenticated = await auth.authenticate(
        localizedReason: 'Please authenticate to access your account',
        options: const local_auth.AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      return authenticated;
    } on PlatformException catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth0 = Auth0Provider.of(context)!.auth0;
    Intl.defaultLocale = LocaleSettings.currentLocale.languageTag;

    // Return a loading indicator while checking login status
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
        navigatorObservers: [MainLayoutNavObserver()],
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
        home: (isLoggedIn
            ? TabsPage()
            : Auth0Service(
                auth0: auth0)) // Show home if logged in, otherwise show login

        );
  }
}
