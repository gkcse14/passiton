import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import './app_navigation.dart';
import '../core/modal_notifier.dart';

class AppScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const AppScaffold({required this.navigationShell, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: ValueListenableBuilder<int>(
        valueListenable: modalCount,
        builder: (context, count, child) {
          return AnimatedSlide(
            offset: count > 0 ? const Offset(0, 1.5) : Offset.zero,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            child: AnimatedOpacity(
              opacity: count > 0 ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 180),
              child: child,
            ),
          );
        },
        child: AppNavigation(navigationShell: navigationShell),
      ),
    );
  }
}
