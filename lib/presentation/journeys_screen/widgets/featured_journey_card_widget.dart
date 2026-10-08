import 'package:flutter/material.dart';
import '../../../core/models/journey_models.dart';
import '../../../core/data/sample_data.dart';
import '../../../theme/app_theme.dart';
import '../../onboarding_screen/widgets/object_artwork_widget.dart';

// Anatomy locked: full-width dark surface card, "UP NEXT" label, title, stats row
class FeaturedJourneyCardWidget extends StatelessWidget {
  final JourneyObject journey;
  final List<JourneyStop> stops;
  final VoidCallback onTap;

  const FeaturedJourneyCardWidget({
    required this.journey,
    required this.stops,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final stats = computeStats(journey.id, stops);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E4038), Color(0xFF0D2820)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E4038).withAlpha(102),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // UP NEXT label
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(38),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'FEATURED',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      journey.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.route_rounded,
                          size: 13,
                          color: Colors.white54,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            journey.mission,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        _statChip(
                          Icons.people_rounded,
                          '${stats.people}',
                          'people',
                        ),
                        _statChip(
                          Icons.public_rounded,
                          '${stats.countries}',
                          'countries',
                        ),
                      ],
                    ),
                    if (journey.goalType == GoalType.countries &&
                        journey.goalTarget != null) ...[
                      const SizedBox(height: 10),
                      _goalProgress(stats.countries, journey.goalTarget!),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Hero(
                tag: 'object-artwork-${journey.id}',
                child: ObjectShowcase(type: journey.type, size: 98),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statChip(IconData icon, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.white54),
        const SizedBox(width: 4),
        Text(
          '$value $label',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _goalProgress(int current, int target) {
    final progress = (current / target).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '$current / $target countries',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
            minHeight: 4,
          ),
        ),
      ],
    );
  }
}
