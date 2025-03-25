import 'package:flutter/material.dart';
import 'package:parsa/app/notifications/notifications_page.dart';
import 'package:parsa/core/routes/route_utils.dart';

class NotificationBadge extends StatelessWidget {
  final Color? iconColor;

  const NotificationBadge({
    Key? key,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Simplified badge without unread count for now
    return IconButton(
      icon: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.notifications_outlined,
            size: 24,
            color: iconColor ?? Colors.grey[500],
          ),
        ],
      ),
      style: IconButton.styleFrom(
        padding: const EdgeInsets.all(8),
      ),
      onPressed: () {
        // Navigate to the notifications page
        RouteUtils.pushRoute(context, const NotificationsPage());
      },
      tooltip: 'Notificações',
    );
  }
}
