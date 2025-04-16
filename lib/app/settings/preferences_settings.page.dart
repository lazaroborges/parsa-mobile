import 'package:flutter/material.dart';
import 'package:parsa/core/database/services/user-setting/private_mode_service.dart';
import 'package:parsa/core/presentation/widgets/platform_alert_dialogue.dart';
import 'package:parsa/i18n/translations.g.dart';
import 'package:parsa/core/providers/user_data_provider.dart';
import 'package:parsa/core/api/post_methods/post_user_settings.dart';
import 'package:parsa/core/services/notification/permission_service.dart';
import 'package:parsa/core/services/notification/fcm_service.dart';
import 'package:parsa/core/services/notification/notification_preferences_service.dart';
import 'package:parsa/core/utils/shared_preferences_async.dart' as app_prefs;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:url_launcher/url_launcher_string.dart';
import 'dart:io' show Platform;
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
  bool _isLoading = true;
  int _startOfWeek = 7;
  int _startOfMonth = 1;
  bool _startOfMonthWorkingDaysOnly = false;

  // Store ScaffoldMessengerState to avoid "Looking up a deactivated widget's ancestor" error
  ScaffoldMessengerState? _scaffoldMessenger;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Store a reference to ScaffoldMessenger
    _scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = app_prefs.SharedPreferencesAsync.instance;
    _startOfWeek = await prefs.getStartOfWeek();
    _startOfMonth = await prefs.getStartOfMonth();
    _startOfMonthWorkingDaysOnly = await prefs.getStartOfMonthWorkingDaysOnly();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh UI when app resumes from background
    if (state == AppLifecycleState.resumed) {
      setState(() {});
    }
  }

  Future<void> _openSubscriptionManagement() async {
    final String url;
    if (Platform.isIOS) {
      url = 'https://apps.apple.com/account/subscriptions';
    } else {
      url =
          'https://play.google.com/store/account/subscriptions?package=com.parsa.app';
    }

    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Não foi possível abrir a página de gerenciamento de assinaturas')),
        );
      }
    }
  }

  // Request notification permission using the existing permission service
  Future<void> _requestNotificationPermission() async {
    try {
      // Reset FCM initialization state
      FCMService.instance.resetInitializationState();

      // Use the existing permission service
      final permissionGranted =
          await PermissionService.instance.requestNotificationPermission();

      if (permissionGranted) {
        // Initialize FCM and update preferences
        await FCMService.instance.initialize();
        await NotificationPreferencesService.instance.updatePreferences(
          budgetsEnabled: true,
          generalEnabled: true,
        );

        // Update UI
        setState(() {});

        // Show success message
        if (mounted) {
          _scaffoldMessenger!.showSnackBar(
            const SnackBar(
              content: Text('Notificações ativadas com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Guide user to system settings if permission denied
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
        _scaffoldMessenger!.showSnackBar(
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
        leading: Icon(selectedItem.icon ?? Icons.settings),
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
        future: _checkPermissionRequested(),
        builder: (context, requestedSnapshot) {
          if (requestedSnapshot.connectionState == ConnectionState.waiting ||
              _isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Only check actual permission status if it was requested previously
          if (requestedSnapshot.data == true) {
            return FutureBuilder<bool>(
                future: PermissionService.instance.hasNotificationPermission(),
                builder: (context, permissionSnapshot) {
                  final bool showPermissionButton =
                      permissionSnapshot.hasData &&
                          !permissionSnapshot.data! &&
                          requestedSnapshot.data!;

                  return _buildSettingsList(context, t, showPermissionButton);
                });
          }

          // If permission was never requested, don't show button
          return _buildSettingsList(context, t, false);
        },
      ),
    );
  }

  // Helper method to check if permission was requested before
  Future<bool> _checkPermissionRequested() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notification_permission_requested') ?? false;
  }

  // Helper function to safely show snackbar
  void _showSnackBar(String message, {bool isError = true}) {
    if (mounted && _scaffoldMessenger != null) {
      _scaffoldMessenger!.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
        ),
      );
    }
  }

  // Build the settings list with or without notification button
  Widget _buildSettingsList(
      BuildContext context, Translations t, bool showPermissionButton) {
    // Create items for start of week selection
    final startOfWeekItems = [
      SelectItem(
        value: 7,
        label: 'Domingo',
        icon: Icons.calendar_today,
      ),
      SelectItem(
        value: 6,
        label: 'Sábado',
        icon: Icons.calendar_today,
      ),
      SelectItem(
        value: 1,
        label: 'Segunda-feira',
        icon: Icons.calendar_today,
      ),
    ];

    // Create items for start of month selection
    final startOfMonthItems = List.generate(10, (index) {
      final day = index + 1;
      return SelectItem(
        value: day,
        label: 'Dia $day',
        icon: Icons.date_range,
      );
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Removed language section and unused stream builders

          createListSeparator(context, t.settings.security.title),
          StreamBuilder(
            stream: PrivateModeService.instance.getPrivateModeAtLaunch(),
            builder: (context, snapshot) {
              return SwitchListTile(
                title: Text(t.settings.security.private_mode_at_launch),
                subtitle:
                    Text(t.settings.security.private_mode_at_launch_descr),
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
            final isAccrualBasisAccounting =
                userDataProvider.userData?['accrual_basis_accounting'] ?? false;

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
                    await PostUserSettings.updateAccrualBasisAccountingSetting(
                      isAccrualBasisAccounting: value,
                    );

                    // Update the local user data
                    userDataProvider
                        .updateUserData({'accrual_basis_accounting': value});

                    // Update the UI
                    setState(() {});

                    // Show success message
                    _scaffoldMessenger!.showSnackBar(
                      SnackBar(
                        content: Text('Configuração atualizada com sucesso'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    // Show error message
                    _scaffoldMessenger!.showSnackBar(
                      SnackBar(
                        content: Text('Erro ao atualizar configuração: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    print('Error updating competent_user setting: $e');
                  }
                }
              },
            );
          }),
          // Calendar settings section
          createListSeparator(context, "Configurações de Calendário"),

          // Start of Week setting
          ListTile(
            title: const Text("Início da Semana"),
            leading: const Icon(Icons.calendar_view_week),
            trailing: DropdownButton<int>(
              value: _startOfWeek,
              onChanged: (value) async {
                if (value != null) {
                  try {
                    await app_prefs.SharedPreferencesAsync.instance
                        .setStartOfWeek(value);
                    setState(() {
                      _startOfWeek = value;
                    });
                    // Send updated preferences to the backend
                    final success =
                        await PostUserSettings.updateDatePreferences(
                      startOfWeek: _startOfWeek,
                      startOfMonth: _startOfMonth,
                      useWorkingDay: _startOfMonthWorkingDaysOnly,
                    );

                    if (!success && mounted) {
                      _showSnackBar(
                          'Erro ao atualizar início da semana no servidor.');
                    }
                  } catch (e) {
                    print('Error updating start of week: $e');
                    if (mounted) {
                      _showSnackBar('Erro ao atualizar início da semana: $e');
                    }
                  }
                }
              },
              items: startOfWeekItems
                  .map((item) => DropdownMenuItem<int>(
                        value: item.value,
                        child: Text(item.label),
                      ))
                  .toList(),
              underline: Container(),
            ),
          ),

          // Start of Month setting
          ListTile(
            title: const Text('Início do Mês'),
            leading: const Icon(Icons.calendar_today_rounded),
            trailing: DropdownButton<int>(
              value: _startOfMonth,
              onChanged: (value) async {
                if (value != null) {
                  try {
                    await app_prefs.SharedPreferencesAsync.instance
                        .setStartOfMonth(value);
                    setState(() {
                      _startOfMonth = value;
                    });
                    // Send updated preferences to the backend
                    final success =
                        await PostUserSettings.updateDatePreferences(
                      startOfWeek: _startOfWeek,
                      startOfMonth: _startOfMonth,
                      useWorkingDay: _startOfMonthWorkingDaysOnly,
                    );

                    if (!success && mounted) {
                      _showSnackBar(
                          'Erro ao atualizar início do mês no servidor.');
                    }
                  } catch (e) {
                    print('Error updating start of month: $e');
                    if (mounted) {
                      _showSnackBar('Erro ao atualizar início do mês: $e');
                    }
                  }
                }
              },
              items: startOfMonthItems
                  .map((item) => DropdownMenuItem<int>(
                        value: item.value,
                        child: Text(item.label),
                      ))
                  .toList(),
              underline: Container(),
            ),
          ),

          // Working days checkbox
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 4.0),
          //   child: Row(
          //     children: [
          //       Checkbox(
          //         value: _startOfMonthWorkingDaysOnly,
          //         onChanged: (value) async {
          //           if (value != null) {
          //             try {
          //               await app_prefs.SharedPreferencesAsync.instance
          //                   .setStartOfMonthWorkingDaysOnly(value);
          //               setState(() {
          //                 _startOfMonthWorkingDaysOnly = value;
          //               });
          //               // Send updated preferences to the backend
          //               final success =
          //                   await PostUserSettings.updateDatePreferences(
          //                 startOfWeek: _startOfWeek,
          //                 startOfMonth: _startOfMonth,
          //                 useWorkingDay: _startOfMonthWorkingDaysOnly,
          //               );

          //               if (!success && mounted) {
          //                 _showSnackBar(
          //                     'Erro ao atualizar configuração de dias úteis no servidor.');
          //               }
          //             } catch (e) {
          //               print('Error updating working days setting: $e');
          //               if (mounted) {
          //                 _showSnackBar(
          //                     'Erro ao atualizar configuração de dias úteis: $e');
          //               }
          //             }
          //           }
          //         },
          //       ),
          //       const Text('Considerar apenas dias úteis'),
          //     ],
          //   ),
          // ),

          // Add notification section only if permissions were requested but denied
          if (showPermissionButton)
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Notificações desativadas",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Você está perdendo notificações importantes sobre sua conta e orçamentos",
                                style: Theme.of(context).textTheme.bodyMedium,
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
                        icon: const Icon(Icons.notifications_active),
                        label: const Text("Ativar Notificações"),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () async {
                          await _requestNotificationPermission();
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Center(
            child: GestureDetector(
              onTap: _openSubscriptionManagement,
              child: Text(
                'Gerencie sua assinatura',
                style: TextStyle(
                  color: Color(0xFF475466),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
