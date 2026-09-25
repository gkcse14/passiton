import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum BadgeStatus { active, completed, archived, sample, following, new_ }

class StatusBadgeWidget extends StatelessWidget {
  final BadgeStatus status;
  final String? customLabel;

  const StatusBadgeWidget({required this.status, this.customLabel, super.key});

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: config.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        customLabel ?? config.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: config.fg,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  _BadgeConfig _getConfig(BadgeStatus s) {
    switch (s) {
      case BadgeStatus.active:
        return _BadgeConfig(
          'Active',
          AppTheme.secondaryContainer,
          AppTheme.secondary,
        );
      case BadgeStatus.completed:
        return _BadgeConfig(
          'Completed',
          const Color(0xFFE8F5EF),
          AppTheme.success,
        );
      case BadgeStatus.archived:
        return _BadgeConfig(
          'Archived',
          const Color(0xFFF5F5F5),
          AppTheme.textSecondaryLight,
        );
      case BadgeStatus.sample:
        return _BadgeConfig(
          'Sample',
          const Color(0xFFFFF3EE),
          AppTheme.primary,
        );
      case BadgeStatus.following:
        return _BadgeConfig(
          'Following',
          AppTheme.primaryContainer,
          AppTheme.primary,
        );
      case BadgeStatus.new_:
        return _BadgeConfig('New', const Color(0xFFFFF0EB), AppTheme.primary);
    }
  }
}

class _BadgeConfig {
  final String label;
  final Color bg;
  final Color fg;
  const _BadgeConfig(this.label, this.bg, this.fg);
}
