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
      return Scaffold(
        body: Row(
          children: [
            if (wide)
              Container(
                width: 224,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    right: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 28,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              Icon(
                                Icons.all_inclusive_rounded,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'pass it on',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        for (var i = 0; i < appDestinations.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Material(
                              color: Colors.transparent,
                              child: Semantics(
                                button: true,
                                child: ListTile(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  selected: navigationShell.currentIndex == i,
                                  selectedTileColor: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                  leading: Icon(
                                    navigationShell.currentIndex == i
                                        ? appDestinations[i].$2
                                        : appDestinations[i].$1,
                                  ),
                                  title: Text(appDestinations[i].$3),
                                  onTap: () => navigationShell.goBranch(
                                    i,
                                    initialLocation:
                                        navigationShell.currentIndex == i,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: () =>
                              context.push(AppRoutes.createJourneyScreen),
                          icon: const Icon(Icons.add_rounded, size: 20),
                          label: const Text('Start a journey'),
                        ),
                        const Spacer(),
                        Text(
                          'Small things. Big stories.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
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
