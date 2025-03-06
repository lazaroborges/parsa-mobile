import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:parsa/app/layout/tabs.dart';
import 'package:parsa/core/presentation/app_colors.dart';
import 'package:parsa/i18n/translations.g.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:parsa/core/services/auth/auth0_class.dart';
import 'package:parsa/core/utils/shared_preferences_async.dart';
import 'package:parsa/app/onboarding/intake.dart';
final GlobalKey<TabsPageState> tabsPageKey = GlobalKey<TabsPageState>();

// Keep only this utility function if it's used elsewhere
Future<void> launchURL(String urlString) async {
  final Uri url = Uri.parse(urlString);
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    throw 'Could not launch $urlString';
  }
}

// The Auth0Service widget class can be removed since it's replaced by IntroPage
