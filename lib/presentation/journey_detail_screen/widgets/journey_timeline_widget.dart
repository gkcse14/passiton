import 'package:flutter/material.dart';
import '../../../core/models/journey_models.dart';
import '../../../theme/app_theme.dart';

class JourneyTimelineWidget extends StatelessWidget {
  final List<JourneyStop> stops;

  const JourneyTimelineWidget({required this.stops, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (stops.isEmpty) {
      return const Center(child: Text('No stops yet.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: stops.length,
      itemBuilder: (context, index) {
        final stop = stops[index];
        final isLast = index == stops.length - 1;
        final isOrigin = stop.isOrigin;

        // Find parent stop for branch indicator
        JourneyStop? parentStop;
        if (stop.parentStopId != null) {
          try {
            parentStop = stops.firstWhere((s) => s.id == stop.parentStopId);
          } catch (_) {}
        }

        // Check if this stop has siblings (multiple children of same parent)
        final siblings = stop.parentStopId != null
            ? stops.where((s) => s.parentStopId == stop.parentStopId).toList()
            : <JourneyStop>[];
        final hasSiblings = siblings.length > 1;

        return _TimelineItem(
          stop: stop,
          isLast: isLast,
          isOrigin: isOrigin,
          parentStop: parentStop,
          hasSiblings: hasSiblings,
          isDark: isDark,
          theme: theme,
        );
      },
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final JourneyStop stop;
  final bool isLast;
  final bool isOrigin;
  final JourneyStop? parentStop;
  final bool hasSiblings;
  final bool isDark;
  final ThemeData theme;

  const _TimelineItem({
    required this.stop,
    required this.isLast,
    required this.isOrigin,
    required this.parentStop,
    required this.hasSiblings,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline column
          SizedBox(
            width: 40,
            child: Column(
              children: [
                // Node circle
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isOrigin
                        ? AppTheme.primary
                        : (isDark
                              ? AppTheme.surfaceDark
                              : AppTheme.surfaceLight),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isOrigin
                          ? AppTheme.primary
                          : (isDark
                                ? AppTheme.borderDark
                                : AppTheme.borderLight),
                      width: isOrigin ? 0 : 1.5,
                    ),
                  ),
                  child: Center(
                    child: isOrigin
                        ? const Icon(
                            Icons.flag_rounded,
                            size: 16,
                            color: Colors.white,
                          )
                        : Text(
                            stop.displayName.isNotEmpty
                                ? stop.displayName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppTheme.textPrimaryDark
                                  : AppTheme.textPrimaryLight,
                            ),
                          ),
                  ),
                ),
                // Line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: hasSiblings
                          ? AppTheme.primary.withAlpha(77)
                          : (isDark
                                ? AppTheme.borderDark
                                : AppTheme.borderLight),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            isOrigin ? stop.displayName : stop.displayName,
                            style: theme.textTheme.titleSmall,
                          ),
                        ),
                        Text(
                          _relativeTime(stop.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppTheme.textSecondaryDark
                                : AppTheme.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                    // Location
                    if (stop.locationVisibility != LocationVisibility.hidden &&
                        stop.displayLocation.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 12,
                            color: isDark
                                ? AppTheme.textSecondaryDark
                                : AppTheme.textSecondaryLight,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            stop.displayLocation,
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
                    if (stop.locationVisibility ==
                        LocationVisibility.hidden) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(
                            Icons.visibility_off_rounded,
                            size: 12,
                            color: isDark
                                ? AppTheme.textSecondaryDark
                                : AppTheme.textSecondaryLight,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'Hidden location',
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: isDark
                                  ? AppTheme.textSecondaryDark
                                  : AppTheme.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                    // Message
                    if (stop.message != null && stop.message!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        '"${stop.message!}"',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondaryLight,
                          height: 1.5,
                        ),
                      ),
                    ],
                    // Branch indicator
                    if (hasSiblings) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '↗ Branch point',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ],
                    // Parent indicator
                    if (parentStop != null && !isOrigin) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Passed along by ${parentStop!.displayName}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondaryLight,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _relativeTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays > 30) {
      return '${(diff.inDays / 30).round()}mo ago';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else {
      return 'Just now';
    }
  }
}
