-dontwarn android.window.BackEvent%
-keep class com.parsa.** { *; }

# Preserve FlutterActivity and related classes
-keep class io.flutter.embedding.android.FlutterActivity { *; }
-keep class io.flutter.embedding.engine.FlutterEngine { *; }
-keep class io.flutter.plugin.common.MethodChannel { *; }

# Preserve classes used by flutter_inappwebview
-keep class com.pichillilorenzo.flutter_inappwebview.** { *; }
-keep interface com.pichillilorenzo.flutter_inappwebview.** { *; }