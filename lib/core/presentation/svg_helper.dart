import 'package:flutter/services.dart' show rootBundle;

class SvgHelper {
  // Cache to store the monochrome status of SVGs
  static final Map<String, bool> _monochromeCache = {};

  /// Determines if the SVG is monochrome based on its filename.
  /// This method caches the result to improve performance.
  static Future<bool> isMonochrome(String assetPath) async {
    // Return cached result if available
    if (_monochromeCache.containsKey(assetPath)) {
      return _monochromeCache[assetPath]!;
    }

    try {
      final svgContent = await rootBundle.loadString(assetPath);
      // Regex to find all fill colors, excluding 'none'
      final colorRegex = RegExp(r'fill="(?!none)(#?[0-9a-fA-F]{3,6})"');
      final matches =
          colorRegex.allMatches(svgContent).map((m) => m.group(1)).toSet();

      // Determine if it's monochrome
      final isMono = matches.length <= 1;
      // Cache the result
      _monochromeCache[assetPath] = isMono;
      return isMono;
    } catch (e) {
      // Handle error or default to false
      print('Error analyzing SVG at $assetPath: $e');
      _monochromeCache[assetPath] = false;
      return false;
    }
  }
}
