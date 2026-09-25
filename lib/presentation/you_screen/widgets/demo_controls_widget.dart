import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class DemoControlsWidget extends StatelessWidget {
  final bool isDark;
  final VoidCallback onReplayOnboarding;
  final VoidCallback onResetDemo;

  const DemoControlsWidget({
    required this.isDark,
    required this.onReplayOnboarding,
    required this.onResetDemo,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Text(
                'DEMO CONTROLS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Preview only',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
            ),
          ),
          child: Column(
            children: [
              _DemoRow(
                icon: Icons.play_circle_outline_rounded,
                label: 'Replay onboarding',
                isDark: isDark,
                onTap: onReplayOnboarding,
              ),
              _divider(isDark),
              _DemoRow(
                icon: Icons.person_add_outlined,
                label: 'Simulate new participant',
                isDark: isDark,
                onTap: () => _showSimulateNote(context),
              ),
              _divider(isDark),
              _DemoRow(
                icon: Icons.account_tree_outlined,
                label: 'Simulate a branch',
                isDark: isDark,
                onTap: () => _showSimulateNote(context),
              ),
              _divider(isDark),
              _DemoRow(
                icon: Icons.flag_outlined,
                label: 'Simulate country milestone',
                isDark: isDark,
                onTap: () => _showSimulateNote(context),
              ),
              _divider(isDark),
              _DemoRow(
                icon: Icons.preview_rounded,
                label: 'Preview received invitation',
                isDark: isDark,
                onTap: () => _showSimulateNote(context),
              ),
              _divider(isDark),
              _DemoRow(
                icon: Icons.hourglass_empty_rounded,
                label: 'Preview loading state',
                isDark: isDark,
                onTap: () => _showLoadingPreview(context),
              ),
              _divider(isDark),
              _DemoRow(
                icon: Icons.error_outline_rounded,
                label: 'Preview error state',
                isDark: isDark,
                onTap: () => _showErrorPreview(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _divider(bool isDark) {
    return Divider(
      height: 1,
      indent: 48,
      color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
    );
  }

  void _showSimulateNote(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Simulation uses local repository — connect to a journey to run.',
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showLoadingPreview(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Loading preview'),
        content: const SizedBox(
          height: 80,
          child: Center(child: CircularProgressIndicator()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showErrorPreview(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Something went wrong'),
        content: const Text('Couldn\'t load journeys. Pull down to try again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Retry'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }
}

class _DemoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _DemoRow({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      splashColor: AppTheme.primary.withAlpha(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 16, color: AppTheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppTheme.textPrimaryDark
                      : AppTheme.textPrimaryLight,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
            ),
          ],
        ),
      ),
    );
  }
}
