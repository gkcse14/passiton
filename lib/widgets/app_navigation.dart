import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const appDestinations = [
  (Icons.home_outlined, Icons.home_rounded, 'Journeys'),
  (Icons.search_rounded, Icons.travel_explore_rounded, 'Explore'),
  (Icons.person_outline_rounded, Icons.person_rounded, 'You'),
];

class AppNavigation extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const AppNavigation({required this.navigationShell, super.key});
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: scheme.outline)),
        boxShadow: [
          BoxShadow(
            color: scheme.onSurface.withAlpha(12),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: [
          for (final tab in appDestinations)
            NavigationDestination(
              icon: Icon(tab.$1),
              selectedIcon: Icon(tab.$2),
              label: tab.$3,
            ),
        ],
      ),
    );
  }
}
