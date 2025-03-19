import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:parsa/core/services/fcm_service.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _isLoading = true;
  List<dynamic> _notifications = [];
  Map<String, dynamic> _pagination = {
    'page': 1,
    'per_page': 20,
    'total': 0,
    'pages': 0,
  };
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _pagination['page'] = 1;
      });
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final result = await FCMService.instance.fetchNotifications(
        page: _pagination['page'],
        perPage: _pagination['per_page'],
      );

      if (result.containsKey('error')) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = result['error'];
        });
        return;
      }

      setState(() {
        _notifications = result['notifications'] ?? [];
        _pagination = result['pagination'] ?? _pagination;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _loadNextPage() async {
    if (_isLoading || _pagination['page'] >= _pagination['pages']) {
      return;
    }

    setState(() {
      _pagination['page'] = _pagination['page'] + 1;
    });

    await _loadNotifications();
  }

  Future<void> _markAllAsRead() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Marcar todas como lidas'),
        content: const Text('Deseja marcar todas as notificações como lidas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    final success = await FCMService.instance.markAllNotificationsAsRead();

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todas as notificações foram marcadas como lidas'),
          backgroundColor: Colors.green,
        ),
      );
      _loadNotifications(refresh: true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Erro ao marcar notificações como lidas. Tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteNotification(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir notificação'),
        content: const Text('Tem certeza que deseja excluir esta notificação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    final success = await FCMService.instance.deleteNotification(id);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notificação excluída com sucesso'),
          backgroundColor: Colors.green,
        ),
      );
      _loadNotifications(refresh: true);
    } else if (mounted) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao excluir notificação. Tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _markAsRead(String id) async {
    final success = await FCMService.instance.markNotificationAsRead(id);

    if (success && mounted) {
      // Update UI to reflect change
      setState(() {
        final index = _notifications.indexWhere((n) => n['id'] == id);
        if (index != -1) {
          _notifications[index]['is_read'] = true;
        }
      });
    }
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return DateFormat.Hm().format(date); // Today, just show time
      } else if (difference.inDays < 7) {
        return DateFormat.E().format(date); // Within a week, show day name
      } else {
        return DateFormat.yMd().format(date); // Older, show full date
      }
    } catch (e) {
      return isoDate;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'TRANSACTIONS':
        return Colors.blue;
      case 'BUDGETS':
        return Colors.orange;
      case 'ACCOUNTS':
        return Colors.green;
      case 'GENERAL':
      default:
        return Colors.purple;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'TRANSACTIONS':
        return Icons.receipt_long;
      case 'BUDGETS':
        return Icons.account_balance_wallet;
      case 'ACCOUNTS':
        return Icons.account_balance;
      case 'GENERAL':
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
        actions: [
          if (_notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'Marcar todas como lidas',
              onPressed: _markAllAsRead,
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadNotifications(refresh: true),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _notifications.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar notificações',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _loadNotifications(refresh: true),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (_notifications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.notifications_off_outlined,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                'Nenhuma notificação',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Você não tem notificações no momento',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          _loadNextPage();
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _notifications.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _notifications.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final notification = _notifications[index];
          final isRead = notification['is_read'] ?? false;
          final category = notification['category'] ?? 'GENERAL';

          return Dismissible(
            key: Key(notification['id']),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16.0),
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            direction: DismissDirection.endToStart,
            confirmDismiss: (direction) async {
              await _deleteNotification(notification['id']);
              return true;
            },
            child: Card(
              color: isRead
                  ? null
                  : Theme.of(context).colorScheme.primary.withOpacity(0.1),
              margin:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              child: InkWell(
                onTap: () {
                  if (!isRead) {
                    _markAsRead(notification['id']);
                  }
                  // Handle navigation here based on notification data
                  final data = notification['data'];
                  if (data != null &&
                      data is Map &&
                      data.containsKey('route')) {
                    final route = data['route'];
                    // Handle navigation to specific route
                    if (kDebugMode) {
                      print('Navigate to route: $route');
                    }
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _getCategoryColor(category).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Icon(
                          _getCategoryIcon(category),
                          color: _getCategoryColor(category),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    notification['title'] ?? '',
                                    style: TextStyle(
                                      fontWeight: isRead
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  _formatDate(notification['created_at'] ?? ''),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notification['message'] ?? '',
                              style: TextStyle(
                                color: Colors.grey[700],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
