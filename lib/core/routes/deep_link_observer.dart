import 'package:flutter/material.dart';

class DeepLinkObserver extends NavigatorObserver {
  final Function(String) onDeepLink;

  DeepLinkObserver(this.onDeepLink);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final settings = route.settings;
    if (settings.name != null &&
        settings.name!.startsWith('com.parsa.app://')) {
      onDeepLink(settings.name!);
    }
  }
}
