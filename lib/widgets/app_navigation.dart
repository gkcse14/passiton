import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../presentation/journeys_screen/widgets/journey_discovery_widgets.dart';

class AppNavigation extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const AppNavigation({required this.navigationShell, super.key});
  @override
  Widget build(BuildContext context) {
    final colors = JourneyColors(context);
    final reduced = MediaQuery.disableAnimationsOf(context);
    const tabs = [
      (Icons.explore_outlined, Icons.explore_rounded, 'Journeys'),
      (Icons.search_rounded, Icons.travel_explore_rounded, 'Explore'),
      (Icons.person_outline_rounded, Icons.person_rounded, 'You'),
    ];
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
        child: Align(
          heightFactor: 1,
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              height: 66,
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: colors.line),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(colors.dark ? 50 : 14),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: List.generate(tabs.length, (i) {
                  final selected = i == navigationShell.currentIndex;
                  final tab = tabs[i];
                  return Expanded(
                    child: Semantics(
                      selected: selected,
                      button: true,
                      label: tab.$3,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () => navigationShell.goBranch(
                            i,
                            initialLocation: selected,
                          ),
                          child: AnimatedContainer(
                            duration: reduced
                                ? Duration.zero
                                : const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: selected
                                  ? colors.sage
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: ExcludeSemantics(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    selected ? tab.$2 : tab.$1,
                                    size: 21,
                                    color: selected ? colors.ink : colors.muted,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    tab.$3,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: selected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: selected
                                          ? colors.ink
                                          : colors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
