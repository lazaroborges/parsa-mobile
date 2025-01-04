import 'dart:io';
import 'package:parsa/core/providers/app_version_provider.dart';

class CustomHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final platform = Platform.isIOS ? 'iOS' : 'Android';
    return super.createHttpClient(context)
      ..userAgent = '($platform) Parsa/${AppVersionProvider.instance.fullVersion}';
  }
}