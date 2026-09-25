import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

// V2 Floating Pill — detached bar, rounded all sides, scroll-aware
// LOCKED: floating pill, shadow, AnimatedContainer active indicator

class _TabSpec {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int? branchIndex;

  const _TabSpec({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.branchIndex,
  });
}

class AppNavigation extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  const AppNavigation({required this.navigationShell, super.key});

  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation> {
  int _selectedVisualIndex = 0;

  static const List<_TabSpec> _tabs = [
    _TabSpec(
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore,
      label: 'Journeys',
      branchIndex: 0,
    ),
    _TabSpec(
      icon: Icons.search_outlined,
      activeIcon: Icons.search,
      label: 'Explore',
      branchIndex: 1,
    ),
    _TabSpec(
      icon: Icons.notifications_outlined,
      activeIcon: Icons.notifications,
      label: 'Activity',
      branchIndex: null, // stub tab
    ),
    _TabSpec(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'You',
      branchIndex: 2,
    ),
  ];

  void _onTabTap(int visualIndex) {
    final spec = _tabs[visualIndex];
    if (spec.branchIndex == null) return; // stub tab — silent ignore
    setState(() => _selectedVisualIndex = visualIndex);
    widget.navigationShell.goBranch(
      spec.branchIndex!,
      initialLocation: spec.branchIndex == widget.navigationShell.currentIndex,
    );
  }

  @override
  void didUpdateWidget(AppNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync visual index with shell's current branch
    final currentBranch = widget.navigationShell.currentIndex;
    for (int i = 0; i < _tabs.length; i++) {
      if (_tabs[i].branchIndex == currentBranch) {
        if (_selectedVisualIndex != i) {
          setState(() => _selectedVisualIndex = i);
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPadding + 12),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: List.generate(_tabs.length, (i) {
            final tab = _tabs[i];
            final isActive = i == _selectedVisualIndex;
            final isStub = tab.branchIndex == null;
            return Expanded(
              child: GestureDetector(
                onTap: () => _onTabTap(i),
                behavior: HitTestBehavior.opaque,
                child: Opacity(
                  opacity: isStub ? 0.4 : 1.0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppTheme.primary.withAlpha(31)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            isActive ? tab.activeIcon : tab.icon,
                            key: ValueKey(isActive),
                            size: 22,
                            color: isActive
                                ? AppTheme.primary
                                : (isDark
                                      ? AppTheme.textSecondaryDark
                                      : AppTheme.textSecondaryLight),
                          ),
                        ),
                        const SizedBox(height: 2),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isActive
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isActive
                                ? AppTheme.primary
                                : (isDark
                                      ? AppTheme.textSecondaryDark
                                      : AppTheme.textSecondaryLight),
                          ),
                          child: Text(tab.label),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
