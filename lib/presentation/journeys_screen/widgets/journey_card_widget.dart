import 'package:flutter/material.dart';
import '../../../core/models/journey_models.dart';
import '../../../core/data/sample_data.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/status_badge_widget.dart';
import '../../onboarding_screen/widgets/object_artwork_widget.dart';

// V4 Gradient Accent card — left border gradient + subtle background tint
// Anatomy locked: artwork left + info column right + stats row bottom
class JourneyCardWidget extends StatelessWidget {
  final JourneyObject journey;
  final List<JourneyStop> stops;
  final VoidCallback onTap;

  const JourneyCardWidget({
    required this.journey,
    required this.stops,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final stats = computeStats(journey.id, stops);
    final accentColor = journey.type.accentColor;

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
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left accent bar
            Container(
              width: 4,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [accentColor, accentColor.withAlpha(77)],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
            ),
            // Artwork
            Padding(
              padding: const EdgeInsets.all(14),
              child: Hero(
                tag: 'object-artwork-${journey.id}-card',
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: accentColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: ObjectArtworkWidget(type: journey.type, size: 54),
                  ),
                ),
              ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            journey.name,
                            style: theme.textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (journey.isSampleData)
                          StatusBadgeWidget(status: BadgeStatus.sample),
                        if (journey.isFollowed && !journey.isSampleData)
                          StatusBadgeWidget(status: BadgeStatus.following),
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
                        _miniStat(
                          context,
                          Icons.people_rounded,
                          '${stats.people}',
                          isDark,
                        ),
                        const SizedBox(width: 12),
                        _miniStat(
                          context,
                          Icons.public_rounded,
                          '${stats.countries}',
                          isDark,
                        ),
                        if (stats.estimatedKm != null) ...[
                          const SizedBox(width: 12),
                          _miniStat(
                            context,
                            Icons.route_rounded,
                            '~${(stats.estimatedKm! / 1000).toStringAsFixed(1)}k km',
                            isDark,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 18,
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

  Widget _miniStat(
    BuildContext context,
    IconData icon,
    String value,
    bool isDark,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 12,
          color: isDark
              ? AppTheme.textSecondaryDark
              : AppTheme.textSecondaryLight,
        ),
        const SizedBox(width: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark
                ? AppTheme.textSecondaryDark
                : AppTheme.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}
