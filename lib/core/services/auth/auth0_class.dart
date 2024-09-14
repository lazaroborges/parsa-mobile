import 'package:flutter/material.dart';
import 'package:auth0_flutter/auth0_flutter.dart';

class Auth0Provider extends InheritedWidget {
  final Auth0 auth0;

  const Auth0Provider({
    Key? key,
    required this.auth0,
    required Widget child,
  }) : super(key: key, child: child);

  static Auth0Provider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Auth0Provider>();
  }

  @override
  bool updateShouldNotify(Auth0Provider oldWidget) {
    return auth0 != oldWidget.auth0;
  }
}
