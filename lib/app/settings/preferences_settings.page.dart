import 'package:flutter/material.dart';
import 'package:parsa/core/database/services/user-setting/private_mode_service.dart';
import 'package:parsa/core/presentation/widgets/platform_alert_dialogue.dart';
import 'package:parsa/i18n/translations.g.dart';
import 'package:parsa/core/providers/user_data_provider.dart';
import 'package:parsa/core/api/post_methods/post_user_settings.dart';
import 'package:parsa/core/services/notification/permission_service.dart';
import 'package:parsa/core/services/notification/notification_preferences_service.dart';
import 'package:parsa/core/utils/shared_preferences_async.dart' as app_prefs;
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:url_launcher/url_launcher_string.dart';
import 'dart:io' show Platform;
import 'widgets/settings_list_separator.dart';
import 'package:parsa/core/services/notification/fcm_service.dart';
import 'package:permission_handler/permission_handler.dart';

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

  // Store notification preferences
  Map<String, bool> _notificationPrefs = {};

  // Store ScaffoldMessengerState to avoid "Looking up a deactivated widget's ancestor" error
  ScaffoldMessengerState? _scaffoldMessenger;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final prefs = app_prefs.SharedPreferencesAsync.instance;
      _startOfWeek = await prefs.getStartOfWeek();
      _startOfMonth = await prefs.getStartOfMonth();
      _startOfMonthWorkingDaysOnly =
          await prefs.getStartOfMonthWorkingDaysOnly();

      // Fetch notification preferences from API using the service
      _notificationPrefs = await NotificationPreferencesService.instance
          .getPreferences(forceRefresh: true);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading preferences: $e');
      }
      _showSnackBar('Erro ao carregar preferências', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh UI and preferences when app resumes from background
    if (state == AppLifecycleState.resumed) {
      _loadPreferences();
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

  /// Ensure we have OS-level notification permission, asking or redirecting if needed
  Future<bool> _ensureNotificationPermission() async {
    // Mark we asked and attempt the platform request
    final granted =
        await PermissionService.instance.requestNotificationPermission();
    if (granted) {
      // Initialize FCM now that permission is granted
      await FCMService.instance.initialize();
      return true;
    }
    // If denied, prompt user to open system settings
    final goToSettings = await showPlatformAlertDialog(
      context: context,
      title: "Permissão Negada",
      content:
          "Para receber notificações, habilite as permissões nas configurações do seu dispositivo.",
      cancelActionText: "Cancelar",
      defaultActionText: "Ir para Configurações",
    );
    if (goToSettings == true) {
      await openAppSettings();
    }
    return false;
  }

  /// Update a notification preference and refresh UI
  Future<void> _updateNotificationPreference({
    bool? budgetsEnabled,
    bool? generalEnabled,
    bool? transactionsEnabled,
    bool? accountEnabled,
  }) async {
    try {
      // Call API service to update preferences
      final success =
          await NotificationPreferencesService.instance.updatePreferences(
        budgetsEnabled: budgetsEnabled,
        generalEnabled: generalEnabled,
        transactionsEnabled: transactionsEnabled,
        accountEnabled: accountEnabled,
      );

      if (success) {
        // Reload preferences from API to ensure UI reflects current state
        _notificationPrefs = await NotificationPreferencesService.instance
            .getPreferences(forceRefresh: true);

        setState(() {});
      } else {
        _showSnackBar('Erro ao atualizar preferência de notificação',
            isError: true);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating notification preference: $e');
      }
      _showSnackBar('Erro ao atualizar preferência de notificação: $e',
          isError: true);
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
        future: PermissionService.instance.hasNotificationPermission(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              _isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final bool hasPermission = snapshot.data ?? false;

          return _buildSettingsList(
            context,
            t,
            hasPermission,
          );
        },
      ),
    );
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

  // Build the settings list with notification toggles
  Widget _buildSettingsList(
    BuildContext context,
    Translations t,
    bool notificationsEnabled,
  ) {
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

    return RefreshIndicator(
      onRefresh: _loadPreferences,
      child: SingleChildScrollView(
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
                  userDataProvider.userData?['accrual_basis_accounting'] ??
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
            createListSeparator(context, "Calendário"),

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

                      if (success) {
                        if (kDebugMode) {
                          print(
                              'Successfully updated start of week preference');
                        }
                      } else if (mounted) {
                        _showSnackBar(
                            'Erro ao atualizar início da semana no servidor.');
                      }
                    } catch (e) {
                      if (kDebugMode) {
                        print('Error updating start of week: $e');
                      }
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

                      if (success) {
                        if (kDebugMode) {
                          print(
                              'Successfully updated start of month preference');
                        }
                      } else if (mounted) {
                        _showSnackBar(
                            'Erro ao atualizar início do mês no servidor.');
                      }
                    } catch (e) {
                      if (kDebugMode) {
                        print('Error updating start of month: $e');
                      }
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

            createListSeparator(context, 'Notificações'),

            // Debug section - shows current permission and preference states
            if (kDebugMode)
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Debug Info:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Permission granted: $notificationsEnabled'),
                    Text('Preferences: $_notificationPrefs'),
                  ],
                ),
              ),

            // Notification category toggles
            SwitchListTile(
              title: const Text('Geral'),
              value: notificationsEnabled
                  ? _notificationPrefs['general_enabled'] ?? false
                  : false,
              onChanged: (bool value) async {
                // If enabling, ensure we have OS permission
                if (value && !notificationsEnabled) {
                  if (!await _ensureNotificationPermission()) return;
                }
                // Update preference through dedicated method
                await _updateNotificationPreference(generalEnabled: value);
              },
            ),
            SwitchListTile(
              title: const Text('Orçamentos'),
              value: notificationsEnabled
                  ? _notificationPrefs['budgets_enabled'] ?? false
                  : false,
              onChanged: (bool value) async {
                if (value && !notificationsEnabled) {
                  if (!await _ensureNotificationPermission()) return;
                }
                await _updateNotificationPreference(budgetsEnabled: value);
              },
            ),
            SwitchListTile(
              title: const Text('Transações'),
              value: notificationsEnabled
                  ? _notificationPrefs['transactions_enabled'] ?? false
                  : false,
              onChanged: (bool value) async {
                if (value && !notificationsEnabled) {
                  if (!await _ensureNotificationPermission()) return;
                }
                await _updateNotificationPreference(transactionsEnabled: value);
              },
            ),
            SwitchListTile(
              title: const Text('Conta'),
              value: notificationsEnabled
                  ? _notificationPrefs['account_enabled'] ?? false
                  : false,
              onChanged: (bool value) async {
                if (value && !notificationsEnabled) {
                  if (!await _ensureNotificationPermission()) return;
                }
                await _updateNotificationPreference(accountEnabled: value);
              },
            ),
            const SizedBox(height: 24),

            // Subscription management section
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
          ],
        ),
      ),
    );
  }
}
