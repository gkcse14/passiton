import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class ProfileStatsWidget extends StatelessWidget {
  final int started;
  final int joined;
  final int following;
  final bool isDark;

  const ProfileStatsWidget({
    required this.started,
    required this.joined,
    required this.following,
    required this.isDark,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
        ),
      ),
      child: Row(
        children: [
          _statCell(context, '$started', 'Started', isDark),
          _divider(isDark),
          _statCell(context, '$joined', 'Joined', isDark),
          _divider(isDark),
          _statCell(context, '$following', 'Following', isDark),
        ],
      ),
    );
  }

  Widget _statCell(
    BuildContext context,
    String value,
    String label,
    bool isDark,
  ) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider(bool isDark) {
    return Container(
      width: 1,
      height: 40,
      color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
    );
  }
}
