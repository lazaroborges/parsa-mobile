import 'dart:io';
import 'package:parsa/core/providers/app_version_provider.dart';

class CustomHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..userAgent = 'Parsa/${AppVersionProvider.instance.fullVersion}';
  }
}