import 'package:flutter/material.dart';
import '../../../core/models/journey_models.dart';

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
    final metrics = [
      (Icons.people_outline_rounded, '${stats.people}', 'People'),
      (Icons.public_rounded, '${stats.countries}', 'Countries'),
      (Icons.location_city_outlined, '${stats.cities}', 'Cities'),
      (
        Icons.route_outlined,
        stats.estimatedKm == null ? '—' : '~${_formatKm(stats.estimatedKm!)}',
        'Est. km',
      ),
    ];
    final target = journey.goalTarget ?? 0;
    final current = journey.goalType == GoalType.countries
        ? stats.countries
        : stats.people;
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, box) {
                final columns =
                    box.maxWidth < 300 ||
                        MediaQuery.textScalerOf(context).scale(14) > 20
                    ? 2
                    : 4;
                return Wrap(
                  spacing: 12,
                  runSpacing: 20,
                  children: [
                    for (final metric in metrics)
                      SizedBox(
                        width: (box.maxWidth - 12 * (columns - 1)) / columns,
                        child: Column(
                          children: [
                            Icon(
                              metric.$1,
                              size: 20,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 8),
                            Text(metric.$2, style: theme.textTheme.titleLarge),
                            const SizedBox(height: 4),
                            Text(metric.$3, style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
            if (journey.goalType != GoalType.none && target > 0) ...[
              const SizedBox(height: 24),
              Text(
                '$current of $target ${journey.goalType == GoalType.countries ? 'countries' : 'people'}',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  semanticsLabel: 'Journey goal',
                  ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatKm(double km) =>
      km >= 1000 ? '${(km / 1000).toStringAsFixed(1)}k' : km.round().toString();
}
