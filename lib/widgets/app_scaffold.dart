import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routes/app_routes.dart';
import 'app_navigation.dart';

class AppScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const AppScaffold({required this.navigationShell, super.key});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final wide = box.maxWidth >= 900;
      final scheme = Theme.of(context).colorScheme;
      final text = Theme.of(context).textTheme;
      return Scaffold(
        body: Row(
          children: [
            if (wide)
              Container(
                width: 260,
                decoration: BoxDecoration(
                  color: scheme.surface,
                  border: Border(right: BorderSide(color: scheme.outline)),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: scheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  Icons.all_inclusive_rounded,
                                  color: scheme.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('pass it on', style: text.titleLarge),
                                    Text(
                                      'Small things. Big stories.',
                                      style: text.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        for (var i = 0; i < appDestinations.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Material(
                              color: Colors.transparent,
                              child: Semantics(
                                button: true,
                                child: ListTile(
                                  shape: const StadiumBorder(),
                                  selected: navigationShell.currentIndex == i,
                                  selectedTileColor: scheme.primaryContainer,
                                  iconColor: scheme.onSurfaceVariant,
                                  selectedColor: scheme.primary,
                                  leading: Icon(
                                    navigationShell.currentIndex == i
                                        ? appDestinations[i].$2
                                        : appDestinations[i].$1,
                                  ),
                                  title: Text(
                                    appDestinations[i].$3,
                                    style: TextStyle(
                                      fontWeight:
                                          navigationShell.currentIndex == i
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                    ),
                                  ),
                                  onTap: () => navigationShell.goBranch(
                                    i,
                                    initialLocation:
                                        navigationShell.currentIndex == i,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () =>
                              context.push(AppRoutes.createJourneyScreen),
                          icon: const Icon(Icons.add_rounded, size: 20),
                          label: const Text('Start a journey'),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'A small act can travel a long way.',
                            style: text.bodySmall?.copyWith(
                              color: scheme.onPrimaryContainer,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Expanded(child: Semantics(container: true, child: navigationShell)),
          ],
        ),
        bottomNavigationBar: wide
            ? null
            : AppNavigation(navigationShell: navigationShell),
      );
    },
  );
}
