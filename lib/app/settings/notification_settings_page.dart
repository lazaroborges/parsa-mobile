import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:parsa/core/services/fcm_service.dart';
import 'package:parsa/core/services/permission_service.dart';
import 'package:parsa/i18n/translations.g.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parsa/app/notifications/notifications_page.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _isLoading = true;
  bool _notificationsEnabled = false;
  String? _fcmToken;

  // Notification category filters
  Map<NotificationCategory, bool> _notificationFilters = {};

  @override
  void initState() {
    super.initState();
    _checkNotificationStatus();
    _loadNotificationPreferences();
  }

  Future<void> _loadNotificationPreferences() async {
    // Initialize with current values from FCMService
    setState(() {
      _notificationFilters = {
        NotificationCategory.transactions: FCMService.instance
            .getNotificationFilter(NotificationCategory.transactions),
        NotificationCategory.budgets: FCMService.instance
            .getNotificationFilter(NotificationCategory.budgets),
        NotificationCategory.accounts: FCMService.instance
            .getNotificationFilter(NotificationCategory.accounts),
        NotificationCategory.general: FCMService.instance
            .getNotificationFilter(NotificationCategory.general),
      };
    });
  }

  Future<void> _saveNotificationPreferences() async {
    // Update FCM service with new preferences
    await FCMService.instance
        .updateNotificationPreferences(_notificationFilters);

    // Sync with the backend
    await FCMService.instance.syncNotificationPreferencesWithBackend();

    // Optional: Save to shared preferences for persistence
    final prefs = await SharedPreferences.getInstance();
    for (var entry in _notificationFilters.entries) {
      prefs.setBool(
          'notification_${entry.key.toString().split('.').last}', entry.value);
    }
  }

  Future<void> _checkNotificationStatus() async {
    final hasPermission =
        await PermissionService.instance.hasNotificationPermission();
    final token = await FCMService.instance.getToken();

    setState(() {
      _notificationsEnabled = hasPermission;
      _fcmToken = token;
      _isLoading = false;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() {
      _isLoading = true;
    });

    if (value) {
      // Enable notifications
      final permissionGranted =
          await PermissionService.instance.requestNotificationPermission();
      if (permissionGranted) {
        // Update all categories to enabled
        for (var key in _notificationFilters.keys) {
          _notificationFilters[key] = true;
        }
        await _saveNotificationPreferences();
      }

      setState(() {
        _notificationsEnabled = permissionGranted;
        _isLoading = false;
      });
    } else {
      // Disable notifications - we can't really revoke permissions, but we can unsubscribe from topics
      // Update all categories to disabled
      for (var key in _notificationFilters.keys) {
        _notificationFilters[key] = false;
      }
      await _saveNotificationPreferences();

      // Delete the FCM token
      await FCMService.instance.deleteToken();

      setState(() {
        _notificationsEnabled = false;
        _fcmToken = null;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Notificações desativadas. Você pode gerenciar as permissões nas configurações do sistema.'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _toggleCategoryNotification(
      NotificationCategory category, bool value) async {
    setState(() {
      _notificationFilters[category] = value;
    });

    await _saveNotificationPreferences();
  }

  String _getCategoryTitle(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.transactions:
        return 'Lembretes de Transações';
      case NotificationCategory.budgets:
        return 'Alertas de Orçamento';
      case NotificationCategory.accounts:
        return 'Atualizações de Contas';
      case NotificationCategory.general:
        return 'Notificações Gerais';
    }
  }

  String _getCategoryDescription(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.transactions:
        return 'Receber lembretes para registrar suas transações';
      case NotificationCategory.budgets:
        return 'Ser notificado quando você se aproximar do limite do orçamento';
      case NotificationCategory.accounts:
        return 'Receber atualizações sobre suas contas e saldos';
      case NotificationCategory.general:
        return 'Receber dicas financeiras e atualizações do app';
    }
  }

  Future<void> _refreshToken() async {
    setState(() {
      _isLoading = true;
    });

    await FCMService.instance.deleteToken();
    final newToken = await FCMService.instance.getToken();

    setState(() {
      _fcmToken = newToken;
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Token de notificação atualizado com sucesso!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Histórico de Notificações',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main switch to enable/disable notifications
                  Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.notifications_active),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Ativar Notificações',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    const Text(
                                      'Receba notificações sobre suas finanças e atualizações importantes',
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _notificationsEnabled,
                                onChanged: _toggleNotifications,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (_notificationsEnabled) ...[
                    // Specific notification categories
                    Text(
                      'Tipos de Notificação',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),

                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        children: [
                          // Transactions notifications
                          SwitchListTile(
                            title: Text(_getCategoryTitle(
                                NotificationCategory.transactions)),
                            subtitle: Text(_getCategoryDescription(
                                NotificationCategory.transactions)),
                            value: _notificationFilters[
                                    NotificationCategory.transactions] ??
                                true,
                            onChanged: (value) => _toggleCategoryNotification(
                                NotificationCategory.transactions, value),
                          ),
                          const Divider(height: 1),

                          // Budget notifications
                          SwitchListTile(
                            title: Text(_getCategoryTitle(
                                NotificationCategory.budgets)),
                            subtitle: Text(_getCategoryDescription(
                                NotificationCategory.budgets)),
                            value: _notificationFilters[
                                    NotificationCategory.budgets] ??
                                true,
                            onChanged: (value) => _toggleCategoryNotification(
                                NotificationCategory.budgets, value),
                          ),
                          const Divider(height: 1),

                          // Account notifications
                          SwitchListTile(
                            title: Text(_getCategoryTitle(
                                NotificationCategory.accounts)),
                            subtitle: Text(_getCategoryDescription(
                                NotificationCategory.accounts)),
                            value: _notificationFilters[
                                    NotificationCategory.accounts] ??
                                true,
                            onChanged: (value) => _toggleCategoryNotification(
                                NotificationCategory.accounts, value),
                          ),
                          const Divider(height: 1),

                          // General notifications
                          SwitchListTile(
                            title: Text(_getCategoryTitle(
                                NotificationCategory.general)),
                            subtitle: Text(_getCategoryDescription(
                                NotificationCategory.general)),
                            value: _notificationFilters[
                                    NotificationCategory.general] ??
                                true,
                            onChanged: (value) => _toggleCategoryNotification(
                                NotificationCategory.general, value),
                          ),
                        ],
                      ),
                    ),

                    // Notification token section (for debugging in debug mode)
                    if (kDebugMode) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Informações de Depuração',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Token de Notificação:',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _fcmToken ?? 'Nenhum token disponível',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _refreshToken,
                                child: const Text('Atualizar Token'),
                              ),
                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 8),
                              Text(
                                'Enviar Notificações de Teste:',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildTestNotificationButton(
                                    context,
                                    'Transações',
                                    NotificationCategory.transactions,
                                  ),
                                  _buildTestNotificationButton(
                                    context,
                                    'Orçamentos',
                                    NotificationCategory.budgets,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildTestNotificationButton(
                                    context,
                                    'Contas',
                                    NotificationCategory.accounts,
                                  ),
                                  _buildTestNotificationButton(
                                    context,
                                    'Geral',
                                    NotificationCategory.general,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _triggerAllTestNotifications,
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(40),
                                ),
                                child: const Text(
                                    'Enviar Todas as Notificações de Teste'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
    );
  }

  // Helper method to build test notification buttons
  Widget _buildTestNotificationButton(
      BuildContext context, String label, NotificationCategory category) {
    return ElevatedButton(
      onPressed: () => _triggerTestNotification(category),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(label),
    );
  }

  // Method to trigger a test notification for a specific category
  Future<void> _triggerTestNotification(NotificationCategory category) async {
    setState(() {
      _isLoading = true;
    });

    String title = '';
    String body = '';

    switch (category) {
      case NotificationCategory.transactions:
        title = 'Lembrete de Transação';
        body = 'Não se esqueça de registrar suas transações de hoje!';
        break;
      case NotificationCategory.budgets:
        title = 'Alerta de Orçamento';
        body = 'Você atingiu 80% do seu orçamento mensal de Alimentação.';
        break;
      case NotificationCategory.accounts:
        title = 'Atualização de Conta';
        body = 'Seus dados financeiros foram atualizados com sucesso!';
        break;
      case NotificationCategory.general:
        title = 'Dica Financeira';
        body = 'Economize mais dinheiro configurando metas mensais!';
        break;
    }

    final success = await FCMService.instance.triggerTestNotification(
      title: title,
      body: body,
      category: category,
    );

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Notificação de teste enviada com sucesso!'
              : 'Falha ao enviar notificação de teste. Verifique os logs.'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  // Method to trigger all test notifications
  Future<void> _triggerAllTestNotifications() async {
    setState(() {
      _isLoading = true;
    });

    final results =
        await FCMService.instance.triggerAllCategoryTestNotifications();
    final allSuccessful = results.every((success) => success);

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(allSuccessful
              ? 'Todas as notificações de teste enviadas com sucesso!'
              : 'Algumas notificações de teste falharam. Verifique os logs.'),
          backgroundColor: allSuccessful ? Colors.green : Colors.orange,
        ),
      );
    }
  }
}
