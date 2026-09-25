import 'package:flutter/material.dart';
import '../../../core/models/journey_models.dart';
import '../../../theme/app_theme.dart';

class JourneyStatsWidget extends StatelessWidget {
  final JourneyStats stats;
  final JourneyObject journey;

  const JourneyStatsWidget({
    required this.stats,
    required this.journey,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _statItem(
                context,
                isDark,
                '${stats.people}',
                'People',
                Icons.people_rounded,
              ),
              _divider(isDark),
              _statItem(
                context,
                isDark,
                '${stats.countries}',
                'Countries',
                Icons.public_rounded,
              ),
              _divider(isDark),
              _statItem(
                context,
                isDark,
                '${stats.cities}',
                'Cities',
                Icons.location_city_rounded,
              ),
              _divider(isDark),
              _statItem(
                context,
                isDark,
                stats.estimatedKm != null
                    ? '~${_formatKm(stats.estimatedKm!)}'
                    : '—',
                'Est. km',
                Icons.route_rounded,
              ),
            ],
          ),
          if (journey.goalType != GoalType.none &&
              journey.goalTarget != null) ...[
            const SizedBox(height: 12),
            _buildGoalProgress(context, isDark),
          ],
        ],
      ),
    );
  }

  Widget _statItem(
    BuildContext context,
    bool isDark,
    String value,
    String label,
    IconData icon,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: AppTheme.primary),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppTheme.textPrimaryDark
                  : AppTheme.textPrimaryLight,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
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

  Widget _buildGoalProgress(BuildContext context, bool isDark) {
    final isCountries = journey.goalType == GoalType.countries;
    final current = isCountries ? stats.countries : stats.people;
    final target = journey.goalTarget!;
    final progress = (current / target).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$current of $target ${isCountries ? 'countries' : 'people'}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppTheme.textPrimaryDark
                    : AppTheme.textPrimaryLight,
              ),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: isDark
                ? AppTheme.borderDark
                : AppTheme.borderLight,
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
          ),
        ),
      ],
    );
  }

  String _formatKm(double km) {
    if (km >= 10000) return '${(km / 1000).round()}k';
    if (km >= 1000) return '${(km / 1000).toStringAsFixed(1)}k';
    return km.round().toString();
  }
}
