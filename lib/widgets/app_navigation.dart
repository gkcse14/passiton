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
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      border: Border(
        top: BorderSide(color: Theme.of(context).colorScheme.outline),
      ),
    ),
    child: NavigationBar(
      selectedIndex: navigationShell.currentIndex,
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
