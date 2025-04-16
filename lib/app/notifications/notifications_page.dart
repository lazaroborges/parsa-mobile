import 'package:flutter/material.dart';
import 'package:parsa/core/services/notification/fcm_service.dart';
import 'package:parsa/core/services/notification/notification_preferences_service.dart';
import 'package:parsa/core/services/notification/notification_service.dart';
import 'package:intl/intl.dart';

// Rename the imported Notification class to avoid conflict with material's Notification
import 'package:parsa/core/services/notification/notification_service.dart'
    as ns;

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _isLoading = true;
  bool _notificationsEnabled = false;
  bool _budgetsEnabled = false;
  bool _generalEnabled = false;

  // Notification list related variables
  List<ns.Notification> _notifications = [];
  bool _isLoadingNotifications = false;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMorePages = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
    _loadNotifications();
  }

  Future<void> _loadNotificationSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get preferences from backend
      final prefs =
          await NotificationPreferencesService.instance.getPreferences();

      setState(() {
        _notificationsEnabled = prefs['budgets_enabled'] == true ||
            prefs['general_enabled'] == true;
        _budgetsEnabled = prefs['budgets_enabled'] ?? false;
        _generalEnabled = prefs['general_enabled'] ?? false;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading notification preferences: $e');
      setState(() {
        _notificationsEnabled = false;
        _budgetsEnabled = false;
        _generalEnabled = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadNotifications({bool refresh = false}) async {
    setState(() {
      _isLoadingNotifications = true;
      if (refresh) {
        _currentPage = 1;
        _notifications = [];
      }
    });

    try {
      final result = await NotificationService.instance.getNotifications(
        page: _currentPage,
        perPage: 10,
      );

      final List<ns.Notification> notifications =
          (result['notifications'] as List<ns.Notification>);

      final pagination = result['pagination'] as Map<String, dynamic>;
      final totalPages = pagination['pages'] as int;

      setState(() {
        if (refresh) {
          _notifications = notifications;
        } else {
          _notifications.addAll(notifications);
        }
        _totalPages = totalPages;
        _hasMorePages = _currentPage < _totalPages;
        _isLoadingNotifications = false;
      });
    } catch (e) {
      print('Error loading notifications: $e');
      setState(() {
        _isLoadingNotifications = false;
      });
    }
  }

  Future<void> _loadNextPage() async {
    if (_hasMorePages && !_isLoadingNotifications) {
      _currentPage++;
      await _loadNotifications();
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    try {
      final success =
          await NotificationService.instance.deleteNotification(notificationId);

      if (success) {
        setState(() {
          _notifications.removeWhere((n) => n.id == notificationId);
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notificação removida com sucesso'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao remover notificação'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error deleting notification: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao remover notificação'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Master toggle for all notifications
  Future<void> _toggleAllNotifications(bool value) async {
    setState(() {
      _isLoading = true;
    });

    // Update backend preferences
    await NotificationPreferencesService.instance.updatePreferences(
      budgetsEnabled: value,
      generalEnabled: value,
    );

    // Update FCM subscriptions
    // await FCMService.instance.setNotificationFilter(NotificationCategory.general, value);

    // Reload settings to ensure UI is in sync with actual state
    await _loadNotificationSettings();
  }

  // Toggle for budget notifications
  Future<void> _toggleBudgetNotifications(bool value) async {
    setState(() {
      _isLoading = true;
    });

    // Update backend preferences
    await NotificationPreferencesService.instance.updatePreferences(
      budgetsEnabled: value,
    );

    // Update FCM subscription
    // await FCMService.instance
    // .setNotificationFilter(NotificationCategory.budgets, value);

    // Reload settings
    await _loadNotificationSettings();
  }

  // Toggle for general notifications
  Future<void> _toggleGeneralNotifications(bool value) async {
    setState(() {
      _isLoading = true;
    });

    // Update backend preferences
    await NotificationPreferencesService.instance.updatePreferences(
      generalEnabled: value,
    );

    // Update FCM subscription
    // await FCMService.instance
    //     .setNotificationFilter(NotificationCategory.general, value);

    // Reload settings
    await _loadNotificationSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _loadNotifications(refresh: true),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Master toggle for all notifications
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.purple.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.notifications_active,
                                color: Colors.purple,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Todas as Notificações',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Ativar ou desativar todas as notificações do app',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _notificationsEnabled,
                              onChanged: _toggleAllNotifications,
                              activeColor: Colors.purple,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Text(
                      'Tipos de notificações',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Individual notification type toggles
                    _buildNotificationTypeCard(
                      context,
                      icon: Icons.account_balance_wallet,
                      title: 'Orçamentos',
                      description:
                          'Receba alertas quando você estiver se aproximando do limite do seu orçamento.',
                      color: Colors.orange,
                      isEnabled: _budgetsEnabled,
                      onToggle: _toggleBudgetNotifications,
                      isDisabled: !_notificationsEnabled,
                    ),
                    const SizedBox(height: 16),

                    _buildNotificationTypeCard(
                      context,
                      icon: Icons.notifications,
                      title: 'Gerais',
                      description:
                          'Novidades, dicas financeiras e lembretes semanais para ajudar a organizar suas finanças.',
                      color: Colors.blue,
                      isEnabled: _generalEnabled,
                      onToggle: _toggleGeneralNotifications,
                      isDisabled: !_notificationsEnabled,
                    ),

                    const SizedBox(height: 32),
                    const Text(
                      'Sobre as notificações',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'As notificações de orçamento são enviadas automaticamente quando você atinge certos limites em seus orçamentos.\n\n'
                      'As notificações gerais incluem lembretes semanais e dicas para melhorar suas finanças.',
                      style: TextStyle(fontSize: 14),
                    ),

                    // Notifications List Section
                    const SizedBox(height: 32),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Suas notificações',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_notifications.isNotEmpty)
                            TextButton.icon(
                              icon: const Icon(Icons.refresh),
                              label: const Text('Atualizar'),
                              onPressed: () =>
                                  _loadNotifications(refresh: true),
                            ),
                        ],
                      ),
                    ),

                    // List of notifications
                    _isLoadingNotifications && _notifications.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : _notifications.isEmpty
                            ? _buildEmptyNotificationsMessage()
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _notifications.length +
                                    (_hasMorePages ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == _notifications.length) {
                                    // Load more indicator
                                    return _buildLoadMoreItem();
                                  }

                                  final notification = _notifications[index];
                                  return _buildNotificationItem(notification);
                                },
                              ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildEmptyNotificationsMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Você não possui notificações',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Suas notificações aparecerão aqui',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreItem() {
    return InkWell(
      onTap: _loadNextPage,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoadingNotifications)
              Container(
                width: 16,
                height: 16,
                margin: const EdgeInsets.only(right: 8),
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            Text(
              _isLoadingNotifications
                  ? 'Carregando mais...'
                  : 'Carregar mais notificações',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(ns.Notification notification) {
    // Determine color based on category
    Color categoryColor;
    IconData categoryIcon;

    switch (notification.category) {
      case 'BUDGETS':
        categoryColor = Colors.orange;
        categoryIcon = Icons.account_balance_wallet;
        break;
      default:
        categoryColor = Colors.blue;
        categoryIcon = Icons.notifications;
        break;
    }

    // Format date
    final formatter = DateFormat('dd/MM/yyyy HH:mm');
    final formattedDate = formatter.format(notification.createdAt);

    return Dismissible(
      key: Key(notification.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _deleteNotification(notification.id),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: notification.isRead ? Colors.transparent : categoryColor,
            width: notification.isRead ? 0 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      categoryIcon,
                      color: categoryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!notification.isRead)
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: categoryColor,
                        shape: BoxShape.circle,
                      ),
                    )
                ],
              ),
              const SizedBox(height: 12),
              Text(
                notification.message,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Deslize para remover',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationTypeCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required bool isEnabled,
    required Function(bool) onToggle,
    bool isDisabled = false,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(isDisabled ? 0.1 : 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isDisabled ? color.withOpacity(0.5) : color,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDisabled ? Colors.grey : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDisabled
                          ? Colors.grey.withOpacity(0.7)
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: isEnabled,
              onChanged: isDisabled ? null : onToggle,
              activeColor: color,
            ),
          ],
        ),
      ),
    );
  }
}
