import 'package:flutter/services.dart' show rootBundle;

Future<String> getIconPath(String iconId) async {
  final defaultPath = 'assets/png_icons/$iconId.png';
  final iconPath = 'assets/png_icons/1.png';

  print('iconId: $iconId');

  try {
    await rootBundle.load(defaultPath);
    return defaultPath;
  } catch (_) {
    return iconPath;
  }
}
