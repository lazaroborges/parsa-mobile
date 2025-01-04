import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersionProvider extends ChangeNotifier {
  String _version = '';
  String _buildNumber = '';
  
  static AppVersionProvider? _instance;
  static AppVersionProvider get instance {
    _instance ??= AppVersionProvider();
    return _instance!;
  }

  String get version => _version;
  String get buildNumber => _buildNumber;
  String get fullVersion => '$_version+$_buildNumber';

  Future<void> initialize() async {
    final packageInfo = await PackageInfo.fromPlatform();
    _version = packageInfo.version;
    _buildNumber = packageInfo.buildNumber;
    notifyListeners();
  }
}