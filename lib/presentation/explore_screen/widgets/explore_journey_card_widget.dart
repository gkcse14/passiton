import 'package:flutter/material.dart';
import '../../../core/models/journey_models.dart';
import '../../../core/data/sample_data.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/status_badge_widget.dart';
import '../../onboarding_screen/widgets/object_artwork_widget.dart';

class ExploreJourneyCardWidget extends StatelessWidget {
  final JourneyObject journey;
  final List<JourneyStop> stops;
  final VoidCallback onTap;
  final VoidCallback onFollow;

  const ExploreJourneyCardWidget({
    required this.journey,
    required this.stops,
    required this.onTap,
    required this.onFollow,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final stats = computeStats(journey.id, stops);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: journey.type.accentColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: ObjectArtworkWidget(type: journey.type, size: 38),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            journey.name,
                            style: theme.textTheme.titleSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (journey.isSampleData)
                          StatusBadgeWidget(status: BadgeStatus.sample),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      journey.mission,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textSecondaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.people_rounded,
                          size: 12,
                          color: isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondaryLight,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${stats.people}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppTheme.textSecondaryDark
                                : AppTheme.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.public_rounded,
                          size: 12,
                          color: isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondaryLight,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${stats.countries} countries',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppTheme.textSecondaryDark
                                : AppTheme.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onFollow,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: journey.isFollowed
                        ? AppTheme.primaryContainer
                        : (isDark
                              ? AppTheme.backgroundDark
                              : AppTheme.backgroundLight),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: journey.isFollowed
                          ? AppTheme.primary
                          : (isDark
                                ? AppTheme.borderDark
                                : AppTheme.borderLight),
                    ),
                  ),
                  child: Icon(
                    journey.isFollowed
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: 16,
                    color: journey.isFollowed
                        ? AppTheme.primary
                        : (isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondaryLight),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
