import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

// V4 Gradient AppBar — custom leading/trailing actions, gradient background
// LOCKED: gradient background, custom actions

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBack;
  final Widget? leading;
  final bool transparent;

  const AppBarWidget({
    required this.title,
    this.actions,
    this.showBack = true,
    this.leading,
    this.transparent = false,
    super.key,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      backgroundColor: transparent
          ? Colors.transparent
          : (isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: showBack
          ? (leading ??
                IconButton(
                  icon: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.surfaceDark
                          : AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark
                            ? AppTheme.borderDark
                            : AppTheme.borderLight,
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimaryLight,
                    ),
                  ),
                  onPressed: () => context.pop(),
                ))
          : null,
      automaticallyImplyLeading: false,
      title: Text(title, style: theme.textTheme.headlineSmall),
      actions: actions,
    );
  }
}
