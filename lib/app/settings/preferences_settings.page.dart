import 'package:flutter/material.dart';
import 'package:parsa/core/database/services/user-setting/private_mode_service.dart';
import 'package:parsa/core/database/services/user-setting/user_setting_service.dart';
import 'package:parsa/core/presentation/widgets/platform_alert_dialogue.dart';
import 'package:parsa/i18n/translations.g.dart';
import 'package:parsa/core/providers/user_data_provider.dart';
import 'package:parsa/core/api/post_methods/post_user_settings.dart';
import 'package:parsa/core/services/notification/permission_service.dart';
import 'package:parsa/core/services/notification/fcm_service.dart';
import 'package:parsa/core/services/notification/notification_preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/widgets.dart';

import 'widgets/settings_list_separator.dart';

class PreferencesSettingsPage extends StatefulWidget {
  const PreferencesSettingsPage({super.key});

  @override
  State<PreferencesSettingsPage> createState() =>
      _PreferencesSettingsPageState();
}

class SelectItem<T> {
  T value;
  String label;

  IconData? icon;

  SelectItem({
    required this.value,
    required this.label,
    this.icon,
  });
}

class _PreferencesSettingsPageState extends State<PreferencesSettingsPage>
    with WidgetsBindingObserver {
  // Add a state variable to track notification permission status
  bool _notificationPermissionDenied = false;
  bool _isLoadingPermissionStatus = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkNotificationPermissionStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Check permission status when app resumes from background
    if (state == AppLifecycleState.resumed) {
      _checkNotificationPermissionStatus();
    }
  }

  // Check if notification permission has been requested and denied
  Future<void> _checkNotificationPermissionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final permissionRequested =
        prefs.getBool('notification_permission_requested') ?? false;

    // Only check permission status if it was requested before
    if (permissionRequested) {
      final hasPermission =
          await PermissionService.instance.hasNotificationPermission();
      setState(() {
        _notificationPermissionDenied = !hasPermission;
        _isLoadingPermissionStatus = false;
      });
    } else {
      setState(() {
        _notificationPermissionDenied = false;
        _isLoadingPermissionStatus = false;
      });
    }
  }

  // Request notification permission again
  Future<void> _requestNotificationPermission() async {
    try {
      // Reset FCM initialization state to allow reinitializing
      FCMService.instance.resetInitializationState();

      final permissionGranted =
          await PermissionService.instance.requestNotificationPermission();

      if (permissionGranted) {
        // Permission granted, update the UI
        setState(() {
          _notificationPermissionDenied = false;
        });

        // Initialize FCM service now that we have permission
        await FCMService.instance.initialize();

        // Enable notifications by default when permission is newly granted
        await NotificationPreferencesService.instance.updatePreferences(
          budgetsEnabled: true,
          generalEnabled: true,
        );

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notificações ativadas com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // If permission still denied, guide the user to system settings
        if (mounted) {
          showPlatformAlertDialog(
            context: context,
            title: "Permissão Negada",
            content:
                "Para receber notificações, você precisa habilitar as permissões nas configurações do seu dispositivo.",
            cancelActionText: "Cancelar",
            defaultActionText: "OK",
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting notification permission: $e');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ocorreu um erro ao solicitar permissão: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget buildSelector<T>({
    required String title,
    String? dialogDescr,
    required List<SelectItem<T>> items,
    required T selected,
    required void Function(T newValue) onChanged,
  }) {
    SelectItem<T> selectedItem =
        items.firstWhere((element) => element.value == selected);

    return ListTile(
        title: Text(title),
        subtitle: Text(selectedItem.label),
        leading: Icon(Icons.light_mode),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title),
                  if (dialogDescr != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      dialogDescr,
                      style: Theme.of(context).textTheme.labelMedium,
                    )
                  ]
                ],
              ),
              contentPadding: const EdgeInsets.only(top: 12),
              content: SingleChildScrollView(
                  child: StatefulBuilder(builder: (context, alertState) {
                return Column(
                    children: items
                        .map(
                          (item) => RadioListTile(
                            title: Text(item.label),
                            value: item.value,
                            groupValue: selected,
                            onChanged: (newValue) {
                              if (newValue != null && newValue != selected) {
                                onChanged(newValue);
                                selected = newValue;
                              }
                            },
                          ),
                        )
                        .toList());
              })),
              actions: [
                TextButton(
                  child: Text(t.general.cancel),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.settings.title_short),
      ),
      body: FutureBuilder<bool>(
          future: _getNotificationPermissionStatus(),
          builder: (context, snapshot) {
            // Update state based on the latest permission status
            if (snapshot.hasData) {
              _notificationPermissionDenied = !snapshot.data!;
              _isLoadingPermissionStatus = false;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // createListSeparator(context, t.settings.lang_section),
                  // ListTile(
                  //   title: Text(t.settings.lang_title),
                  //   leading: const Icon(Icons.language),
                  //   subtitle: Text(
                  //     appSupportedLocales
                  //         .firstWhere((element) =>
                  //             element.locale.languageTag ==
                  //             LocaleSettings.currentLocale.languageTag)
                  //         .label,
                  //   ),
                  //   onTap: () async {
                  //     final snackbarDisplayer =
                  //         ScaffoldMessenger.of(context).showSnackBar;

                  //     final newLang = await showLanguageSelectorBottomSheet(
                  //       context,
                  //       LanguageSelector(
                  //           selectedLangTag:
                  //               LocaleSettings.currentLocale.languageTag),
                  //     );

                  //     if (newLang == null) {
                  //       return;
                  //     }

                  //     LocaleSettings.setLocaleRaw(newLang,
                  //         listenToDeviceLocale: true);

                  //     try {
                  //       await UserSettingService.instance
                  //           .setSetting(SettingKey.appLanguage, newLang);
                  //     } catch (e) {
                  //       snackbarDisplayer(const SnackBar(
                  //         content: Text(
                  //             'There was an error persisting this setting on your device. Contact the developers for more information'),
                  //       ));
                  //     }
                  //   },
                  // ),
                  // // createListSeparator(context, t.settings.theme_and_colors),
                  StreamBuilder(
                      stream: UserSettingService.instance
                          .getSetting(SettingKey.themeMode)
                          .map((event) => 'light'),
                      initialData: 'light',
                      builder: (context, snapshot) {
                        // Not rendering the widget, but keeping the stream active
                        return const SizedBox.shrink();
                      }),
                  // Removed AMOLED mode, dynamic colors, and accent color widgets
                  StreamBuilder(
                      stream: UserSettingService.instance
                          .getSetting(SettingKey.amoledMode)
                          .map((event) => 'light'),
                      initialData: 'light',
                      builder: (context, snapshot) {
                        // Not rendering the widget, but keeping the stream active
                        return const SizedBox.shrink();
                      }),
                  StreamBuilder(
                      stream: UserSettingService.instance
                          .getSetting(SettingKey.accentColor)
                          .map((event) => 'true'),
                      initialData: 'true',
                      builder: (context, snapshot) {
                        // Not rendering the widget, but keeping the stream active
                        return const SizedBox.shrink();
                      }),
                  StreamBuilder(
                      stream: UserSettingService.instance
                          .getSetting(SettingKey.accentColor)
                          .map((event) => 'MaterialBlue3.24'),
                      initialData: 'MaterialBlue3.24',
                      builder: (context, snapshot) {
                        // Not rendering the widget, but keeping the stream active
                        return const SizedBox.shrink();
                      }),
                  createListSeparator(context, t.settings.security.title),
                  StreamBuilder(
                    stream:
                        PrivateModeService.instance.getPrivateModeAtLaunch(),
                    builder: (context, snapshot) {
                      return SwitchListTile(
                        title: Text(t.settings.security.private_mode_at_launch),
                        subtitle: Text(
                            t.settings.security.private_mode_at_launch_descr),
                        secondary: const Icon(Icons.phonelink_lock_outlined),
                        value: snapshot.data ?? false,
                        onChanged: (bool value) async {
                          await PrivateModeService.instance
                              .setPrivateModeAtLaunch(value);
                          setState(() {});
                        },
                      );
                    },
                  ),
                  createListSeparator(context, "Prestações"),
                  Builder(builder: (context) {
                    // Get the initial value from UserDataProvider
                    final userDataProvider = UserDataProvider.instance;
                    final isAccrualBasisAccounting = userDataProvider
                            .userData?['accrual_basis_accounting'] ??
                        false;

                    return SwitchListTile(
                      title: const Text("Regime de Competência"),
                      subtitle: const Text(
                          "Lança o valor total de uma prestação na data da compra."),
                      secondary: const Icon(Icons.calendar_month),
                      value: isAccrualBasisAccounting,
                      onChanged: (bool value) async {
                        // Show confirmation dialog before making the change
                        final confirmed = await showPlatformAlertDialog(
                          context: context,
                          title: "Confirmar alteração",
                          content: value
                              ? "Ativar o regime de competência lançará o valor total de uma compra parcelada na data da compra. Você pode perder dados relacionados a transações editadas anteriormente. Deseja continuar?"
                              : "Desativar o regime de competência irá lançar cada parcela na data de vencimento. Você pode perder dados relacionados a transações editadas anteriormente. Deseja continuar?",
                          cancelActionText: "Cancelar",
                          defaultActionText: "Confirmar",
                        );

                        // If user confirmed, proceed with the change
                        if (confirmed == true) {
                          try {
                            // Update the value in the backend
                            await PostUserSettings
                                .updateAccrualBasisAccountingSetting(
                              isAccrualBasisAccounting: value,
                            );

                            // Update the local user data
                            userDataProvider.updateUserData(
                                {'accrual_basis_accounting': value});

                            // Update the UI
                            setState(() {});

                            // Show success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Configuração atualizada com sucesso'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            // Show error message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Erro ao atualizar configuração: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            print('Error updating competent_user setting: $e');
                          }
                        }
                      },
                    );
                  }),
                  // PrivateMode button disabled for now
                  // StreamBuilder(
                  //     stream: PrivateModeService.instance.privateModeStream,
                  //     builder: (context, snapshot) {
                  //       return SwitchListTile(
                  //         title: Text(t.settings.security.private_mode),
                  //         subtitle: Text(t.settings.security.private_mode_descr),
                  //         secondary: const Icon(Icons.lock),
                  //         value: snapshot.data ?? false,
                  //         onChanged: (bool value) {
                  //           PrivateModeService.instance.setPrivateMode(value);
                  //           setState(() {});
                  //         },
                  //       );
                  //     }),

                  // Add notification section only if permissions have been denied
                  if (_notificationPermissionDenied) ...[
                    _isLoadingPermissionStatus
                        ? const Center(child: CircularProgressIndicator())
                        : Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.notifications_off,
                                          color: Colors.orange),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Notificações desativadas",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "Você está perdendo notificações importantes sobre sua conta e orçamentos",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      icon: const Icon(
                                          Icons.notifications_active),
                                      label: const Text("Ativar Notificações"),
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                      ),
                                      onPressed: () async {
                                        await _requestNotificationPermission();
                                        // Refresh state after permission request
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ],
                ],
              ),
            );
          }),
    );
  }

  // Helper method to get permission status for FutureBuilder
  Future<bool> _getNotificationPermissionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final permissionRequested =
        prefs.getBool('notification_permission_requested') ?? false;

    // Only check permission status if it was requested before
    if (permissionRequested) {
      return await PermissionService.instance.hasNotificationPermission();
    }

    // If permission was never requested, don't show the button
    return true;
  }
}
