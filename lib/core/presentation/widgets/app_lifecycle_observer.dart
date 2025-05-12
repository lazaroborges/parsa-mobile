import 'package:flutter/widgets.dart';

/// A utility class to observe app lifecycle changes.
class AppLifecycleObserver with WidgetsBindingObserver {
  final VoidCallback? onResume;
  final VoidCallback? onPause;
  final VoidCallback? onInactive;
  final VoidCallback? onDetached;

  AppLifecycleObserver({
    this.onResume,
    this.onPause,
    this.onInactive,
    this.onDetached,
  });

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        onResume?.call();
        break;
      case AppLifecycleState.paused:
        onPause?.call();
        break;
      case AppLifecycleState.inactive:
        onInactive?.call();
        break;
      case AppLifecycleState.detached:
        onDetached?.call();
        break;
      default:
        break;
    }
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppLifecycleObserver &&
        other.onResume == onResume &&
        other.onPause == onPause &&
        other.onInactive == onInactive &&
        other.onDetached == onDetached;
  }

  @override
  int get hashCode => 
      onResume.hashCode ^ 
      onPause.hashCode ^ 
      onInactive.hashCode ^ 
      onDetached.hashCode;
} 