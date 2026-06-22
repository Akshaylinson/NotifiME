import 'package:flutter/material.dart';

class AudioLifecycleObserver extends NavigatorObserver {
  final VoidCallback onNavigateBack;

  AudioLifecycleObserver({required this.onNavigateBack});

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    onNavigateBack();
  }
}
