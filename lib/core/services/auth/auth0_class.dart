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

// Global variable to hold the app-wide BuildContext
BuildContext? globalAppContext;

// Helper function to get the Auth0 instance from the global context
Auth0 getAuth0Instance() {
  if (globalAppContext == null) {
    throw Exception('Global app context not set');
  }

  final auth0ProviderGlobal = Auth0Provider.of(globalAppContext!);
  if (auth0ProviderGlobal == null) {
    throw Exception('Auth0Provider not found in the widget tree');
  }

  return auth0ProviderGlobal.auth0;
}
