import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:parsa/core/database/services/user-setting/private_mode_service.dart';
import 'package:parsa/core/presentation/widgets/platform_alert_dialogue.dart';
import 'package:parsa/core/presentation/app_colors.dart';
import 'package:parsa/i18n/translations.g.dart';
import 'package:parsa/core/providers/user_data_provider.dart';
import 'package:parsa/core/api/post_methods/post_user_settings.dart';
import 'package:parsa/core/api/fetch_user_data_server.dart';
import 'package:parsa/core/services/notification/permission_service.dart';
import 'package:parsa/core/services/notification/notification_preferences_service.dart';
import 'package:parsa/core/utils/shared_preferences_async.dart' as app_prefs;
import 'package:parsa/core/utils/open_external_url.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
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

  // Store notification preferences
  Map<String, bool> _notificationPrefs = {};

  // Store ScaffoldMessengerState to avoid "Looking up a deactivated widget's ancestor" error
  ScaffoldMessengerState? _scaffoldMessenger;

  // API Key form state
  final _apiKeyFormKey = GlobalKey<FormState>();
  final _apiKeyController = TextEditingController();
  bool _isSubmittingApiKey = false;

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

      // Check notification permissions
      final hasPermission =
          await PermissionService.instance.hasNotificationPermission();

      // Fetch notification preferences from API using the service
      // Force refresh to ensure we have the latest state
      _notificationPrefs = await NotificationPreferencesService.instance
          .getPreferences(forceRefresh: true);

      if (kDebugMode) {
        print('Notification permission status: $hasPermission');
        print('Notification preferences: $_notificationPrefs');
      }

      // If permission is granted but somehow all preferences are disabled,
      // automatically enable general notifications
      if (hasPermission &&
          !(_notificationPrefs['budgets_enabled'] == true ||
              _notificationPrefs['general_enabled'] == true ||
              _notificationPrefs['transactions_enabled'] == true ||
              _notificationPrefs['account_enabled'] == true)) {
        if (kDebugMode) {
          print(
              'Permission granted but all notifications disabled, enabling general notifications');
        }

        // Enable at least general notifications
        await NotificationPreferencesService.instance.updatePreferences(
          generalEnabled: true,
          budgetsEnabled: true,
          transactionsEnabled: true,
          accountEnabled: true,
        );

        // Reload preferences
        _notificationPrefs = await NotificationPreferencesService.instance
            .getPreferences(forceRefresh: true);
      }
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
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh UI and preferences when app resumes from background
    if (state == AppLifecycleState.resumed) {
      _checkPermissionChanges();
    }
  }

  // Check if notification permissions changed while app was in background
  Future<void> _checkPermissionChanges() async {
    // Store previous permission state before reloading
    final previouslyHadPermission =
        await PermissionService.instance.hasNotificationPermission();

    // Reload all preferences
    await _loadPreferences();

    // Get the current permission state after reloading
    final hasPermissionNow =
        await PermissionService.instance.hasNotificationPermission();

    // If permission was granted while in background or settings
    if (!previouslyHadPermission && hasPermissionNow) {
      if (kDebugMode) {
        print("Notification permission was granted while in background!");
      }

      // Initialize and register FCM token
      await FCMService.instance.handlePermissionGranted();

      // Enable all notification categories since permission was just granted
      await NotificationPreferencesService.instance.updatePreferences(
        budgetsEnabled: true,
        generalEnabled: true,
        transactionsEnabled: true,
        accountEnabled: true,
      );

      // Reload preferences to update UI
      await _loadPreferences();
    }
  }

  Future<void> _submitApiKey() async {
    if (!_apiKeyFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmittingApiKey = true;
    });

    try {
      final success = await PostUserSettings.updateProviderKey(
        providerKey: _apiKeyController.text.trim(),
      );

      if (success && mounted) {
        // Refresh user data to get updated hasValidKey status
        await fetchUserDataAtServer();
        
        // Clear the input field
        _apiKeyController.clear();
        
        setState(() {
          _isSubmittingApiKey = false;
        });

        _showSnackBar('Chave API configurada com sucesso!', isError: false);
      } else if (mounted) {
        setState(() {
          _isSubmittingApiKey = false;
        });
        _showSnackBar('Erro ao configurar chave API. Tente novamente.', isError: true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmittingApiKey = false;
        });
        _showSnackBar('Erro: $e', isError: true);
      }
    }
  }

  /// Ensure we have OS-level notification permission, asking or redirecting if needed
  Future<bool> _ensureNotificationPermission() async {
    // Mark we asked and attempt the platform request
    final granted =
        await PermissionService.instance.requestNotificationPermission();
    if (granted) {
      // Initialize and register FCM token
      await FCMService.instance.handlePermissionGranted();

      // Enable all notification categories since permission was just granted
      await NotificationPreferencesService.instance.updatePreferences(
        budgetsEnabled: true,
        generalEnabled: true,
        transactionsEnabled: true,
        accountEnabled: true,
      );

      // Refresh UI to show new state
      setState(() {
        _notificationPrefs = {
          'budgets_enabled': true,
          'general_enabled': true,
          'transactions_enabled': true,
          'account_enabled': true,
        };
      });

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
      // Store pre-settings permission state
      final preSettingsPermission =
          await PermissionService.instance.hasNotificationPermission();

      // Open settings
      await openAppSettings();

      // After returning from settings, check if permission was granted
      await Future.delayed(const Duration(seconds: 2));
      final postSettingsPermission =
          await PermissionService.instance.hasNotificationPermission();

      // If permission was granted in settings
      if (!preSettingsPermission && postSettingsPermission) {
        // Initialize and register FCM token
        await FCMService.instance.handlePermissionGranted();

        // Enable all notification categories since permission was just granted
        await NotificationPreferencesService.instance.updatePreferences(
          budgetsEnabled: true,
          generalEnabled: true,
          transactionsEnabled: true,
          accountEnabled: true,
        );

        // Reload preferences to update UI
        await _loadPreferences();

        return true;
      }
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

  // Custom Notification Icons for settings
  Widget _buildGeneralNotificationIcon(BuildContext context,
      {bool permissionGranted = true}) {
    return SizedBox(
      width: 24,
      height: 24,
      child: Icon(
        permissionGranted
            ? Icons.notifications_active_outlined
            : Icons.notifications_off_outlined,
        size: 24,
        color: Theme.of(context).iconTheme.color,
      ),
    );
  }

  Widget _buildBudgetNotificationIcon(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: Icon(
        Icons.savings_outlined, // Better icon for budget notifications
        size: 24,
        color: Theme.of(context).iconTheme.color,
      ),
    );
  }

  Widget _buildTransactionNotificationIcon(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: Icon(
        Icons.paid_outlined, // Better icon for transaction notifications
        size: 24,
        color: Theme.of(context).iconTheme.color,
      ),
    );
  }

  Widget _buildAccountNotificationIcon(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: Icon(
        Icons.account_balance_outlined,
        size: 24,
        color: Theme.of(context).iconTheme.color,
      ),
    );
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

            // Create a custom notification section header with permission status indicator
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

            // Always show General switch, but disable it when permissions not granted
            SwitchListTile(
              title: const Text('Geral'),
              value: notificationsEnabled
                  ? _notificationPrefs['general_enabled'] ?? false
                  : false,
              secondary: _buildGeneralNotificationIcon(context,
                  permissionGranted: notificationsEnabled),
              onChanged: (bool value) async {
                // If permissions not granted, always show settings dialog
                if (!notificationsEnabled) {
                  await _ensureNotificationPermission();
                } else {
                  // Otherwise just update the preference
                  await _updateNotificationPreference(generalEnabled: value);
                }
              },
            ),

            // Only show other notification categories if permission is granted
            if (notificationsEnabled) ...[
              SwitchListTile(
                title: const Text('Orçamentos'),
                secondary: _buildBudgetNotificationIcon(context),
                value: _notificationPrefs['budgets_enabled'] ?? false,
                onChanged: (bool value) async {
                  await _updateNotificationPreference(budgetsEnabled: value);
                },
              ),
              SwitchListTile(
                title: const Text('Transações'),
                secondary: _buildTransactionNotificationIcon(context),
                value: _notificationPrefs['transactions_enabled'] ?? false,
                onChanged: (bool value) async {
                  await _updateNotificationPreference(
                      transactionsEnabled: value);
                },
              ),
              SwitchListTile(
                title: const Text('Contas'),
                secondary: _buildAccountNotificationIcon(context),
                value: _notificationPrefs['account_enabled'] ?? false,
                onChanged: (bool value) async {
                  await _updateNotificationPreference(accountEnabled: value);
                },
              ),
            ],
            const SizedBox(height: 24),

            // Open Finance API Key section
            createListSeparator(context, 'Open Finance'),
            _buildOpenFinanceSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOpenFinanceSection(BuildContext context) {
    final appColors = AppColors.of(context);
    final theme = Theme.of(context);
    final userData = context.watch<UserDataProvider>().userData;
    
    // Check for hasValidKey (try both camelCase and snake_case)
    final hasValidKey = userData?['hasValidKey'] == true || 
                        userData?['has_valid_key'] == true;

    if (hasValidKey) {
      // Show positive message when key is valid
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          border: Border.all(color: Colors.green.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.green.shade700,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Chave API Open Finance configurada com sucesso!',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.green.shade900,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Show input form when key is not valid
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: appColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Form(
          key: _apiKeyFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Conectar com Open Finance',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: appColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Para conectar sua conta automaticamente, você precisa:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: appColors.onSurface,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              _buildInstructionStepWithLink(
                context: context,
                step: '1',
                text: 'Acesse o ',
                linkText: 'Pierre Finance',
                linkUrl: 'https://pierre.finance/',
                textAfter: ' e crie uma conta',
              ),
              const SizedBox(height: 8),
              _buildInstructionStep(
                context: context,
                step: '2',
                text: 'Sincronize suas contas bancárias',
              ),
              const SizedBox(height: 8),
              _buildInstructionStep(
                context: context,
                step: '3',
                text: 'Obtenha sua chave API nas configurações',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _apiKeyController,
                decoration: InputDecoration(
                  labelText: 'Chave API',
                  hintText: 'Cole sua chave API aqui',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: appColors.inputFill,
                ),
                enabled: !_isSubmittingApiKey,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira sua chave API';
                  }
                  return null;
                },
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submitApiKey(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmittingApiKey ? null : _submitApiKey,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appColors.primary,
                    foregroundColor: appColors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSubmittingApiKey
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Conectar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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

  Widget _buildInstructionStep({
    required BuildContext context,
    required String step,
    required String text,
  }) {
    final appColors = AppColors.of(context);
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: appColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step,
              style: theme.textTheme.bodySmall?.copyWith(
                color: appColors.onPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: appColors.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionStepWithLink({
    required BuildContext context,
    required String step,
    required String text,
    required String linkText,
    required String linkUrl,
    required String textAfter,
  }) {
    final appColors = AppColors.of(context);
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: appColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step,
              style: theme.textTheme.bodySmall?.copyWith(
                color: appColors.onPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text.rich(
            TextSpan(
              text: text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: appColors.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              children: [
                TextSpan(
                  text: linkText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: appColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      openExternalURL(context, linkUrl);
                    },
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Icon(
                      Icons.open_in_new,
                      size: 14,
                      color: appColors.primary,
                    ),
                  ),
                ),
                TextSpan(
                  text: textAfter,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: appColors.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
