import 'package:flutter/material.dart';
import 'package:parsa/app/accounts/accounts_page.dart';
import 'package:parsa/app/auth/auth_page.dart';
import 'package:parsa/app/auth/login_page.dart';
import 'package:parsa/app/auth/register_page.dart';
import 'package:parsa/app/budgets/budgets_page.dart';
import 'package:parsa/app/dashboard/dashboard_page.dart';
import 'package:parsa/app/settings/settings_page.dart';
import 'package:parsa/app/settings/notification_settings_page.dart';
import 'package:parsa/app/notifications/notifications_page.dart';
import 'package:parsa/app/tabs/tabs_page.dart';
import 'package:parsa/app/transactions/transactions_page.dart';
import 'package:parsa/core/routes/no_transition_builder.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => const TabsPage(),
        );

      case '/auth':
        return MaterialPageRoute(
          builder: (_) => const AuthPage(),
        );

      case '/login':
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
        );

      case '/register':
        return MaterialPageRoute(
          builder: (_) => const RegisterPage(),
        );

      case '/dashboard':
        return NoTransitionRoute(
          builder: (_) => const DashboardPage(),
        );

      case '/transactions':
        return NoTransitionRoute(
          builder: (_) => const TransactionsPage(),
        );

      case '/budgets':
        return NoTransitionRoute(
          builder: (_) => const BudgetsPage(),
        );

      case '/accounts':
        return NoTransitionRoute(
          builder: (_) => const AccountsPage(),
        );

      case '/settings':
        return MaterialPageRoute(
          builder: (_) => const SettingsPage(),
        );

      case '/notifications':
        return MaterialPageRoute(
          builder: (_) => const NotificationsPage(),
        );

      case '/settings/notifications':
        return MaterialPageRoute(
          builder: (_) => const NotificationSettingsPage(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
