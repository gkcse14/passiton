import 'package:flutter/material.dart';
import '../../../core/data/sample_data.dart';
import '../../../core/models/journey_models.dart';
import '../../../core/services/nearby_journeys.dart';
import '../../onboarding_screen/widgets/object_artwork_widget.dart';

class JourneyColors {
  final bool dark;
  JourneyColors(BuildContext context)
    : dark = Theme.of(context).brightness == Brightness.dark;
  Color get ink => dark ? const Color(0xFFF3F0E8) : const Color(0xFF263F36);
  Color get muted => dark ? const Color(0xFFB4BEB5) : const Color(0xFF657167);
  Color get canvas => dark ? const Color(0xFF111B17) : const Color(0xFFFAF9F5);
  Color get surface => dark ? const Color(0xFF1D2A24) : Colors.white;
  Color get sage => dark ? const Color(0xFF293D32) : const Color(0xFFE9EFE4);
  Color get peach => dark ? const Color(0xFF3B3027) : const Color(0xFFF7EADD);
  Color get line => dark ? const Color(0xFF33443B) : const Color(0xFFE5E8DE);
  static const green = Color(0xFF345B49);
  static const orange = Color(0xFFC85D3A);
}

class JourneyWelcome extends StatelessWidget {
  final VoidCallback onCreate;
  const JourneyWelcome({required this.onCreate, super.key});
  @override
  Widget build(BuildContext context) {
    final c = JourneyColors(context);
    return LayoutBuilder(
      builder: (context, box) {
        final wide = box.maxWidth > 650;
        final compact = box.maxWidth < 310;
        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: c.peach,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(painter: WanderingPath(c.ink.withAlpha(18))),
              ),
              Padding(
                padding: EdgeInsets.all(wide ? 36 : 22),
                child: Row(
                  children: [
                    Expanded(
                      flex: wide ? 6 : 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'A LITTLE WONDER, EVERY DAY',
                            style: TextStyle(
                              color: c.ink,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.4,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Small things.\nBig stories.',
                            style: TextStyle(
                              fontSize: wide
                                  ? 46
                                  : compact
                                  ? 25
                                  : 30,
                              height: 1.08,
                              letterSpacing: -1.3,
                              color: c.ink,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Find a little wonder.\nGive its story a new chapter.',
                            style: TextStyle(
                              color: c.ink.withAlpha(180),
                              fontSize: 12,
                              height: 1.55,
                            ),
                          ),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            onPressed: onCreate,
                            style: FilledButton.styleFrom(
                              backgroundColor: JourneyColors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 17,
                                vertical: 14,
                              ),
                            ),
                            icon: const Icon(Icons.add_rounded, size: 17),
                            label: Text(
                              compact ? 'Start a story' : 'Start a journey',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      flex: 4,
                      child: SizedBox(
                        height: wide ? 238 : 220,
                        child: LayoutBuilder(
                          builder: (context, art) => Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                right: -14,
                                top: 48,
                                child: Container(
                                  width: art.maxWidth + 18,
                                  height: art.maxWidth + 18,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: c.surface.withAlpha(100),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 36,
                                left: -12,
                                right: -20,
                                child: ObjectShowcase(
                                  type: ObjectType.potato,
                                  size: wide ? 218 : 150,
                                ),
                              ),
                              Positioned(
                                top: -4,
                                right: 6,
                                child: Transform.rotate(
                                  angle: .18,
                                  child: ObjectArtworkWidget(
                                    type: ObjectType.star,
                                    size: wide ? 72 : 55,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: -18,
                                child: Transform.rotate(
                                  angle: -.18,
                                  child: ObjectArtworkWidget(
                                    type: ObjectType.heart,
                                    size: wide ? 90 : 65,
                                  ),
                                ),
                              ),
                              if (!compact)
                                Positioned(
                                  bottom: 12,
                                  right: -6,
                                  child: Text(
                                    'made to be passed on',
                                    style: TextStyle(
                                      color: c.ink.withAlpha(160),
                                      fontSize: 9,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class WanderingPath extends CustomPainter {
  final Color color;
  WanderingPath(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * .45, size.height * 1.05)
      ..cubicTo(
        size.width * .38,
        size.height * .45,
        size.width * .95,
        size.height * .95,
        size.width * .90,
        size.height * .25,
      )
      ..cubicTo(
        size.width * .88,
        -30,
        size.width * .57,
        20,
        size.width * .67,
        size.height * .3,
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (final metric in path.computeMetrics()) {
      for (double d = 0; d < metric.length; d += 10) {
        canvas.drawPath(metric.extractPath(d, d + 4), paint);
      }
    }
    canvas.drawCircle(
      Offset(size.width * .67, size.height * .3),
      4,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(WanderingPath oldDelegate) => color != oldDelegate.color;
}

class DiscoveryJourneyCard extends StatelessWidget {
  final NearbyJourney item;
  final VoidCallback onOpen;
  final VoidCallback onSave;
  final bool saving;
  const DiscoveryJourneyCard({
    required this.item,
    required this.onOpen,
    required this.onSave,
    this.saving = false,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    final c = JourneyColors(context);
    final journey = item.journey;
    final location =
        item.latestStop?.locationVisibility == LocationVisibility.city
        ? item.latestStop?.cityName ?? 'A new adventure'
        : 'Somewhere wonderful';
    return Material(
      color: c.surface,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(26),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: c.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: journey.type.accentColor.withAlpha(c.dark ? 30 : 24),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: WanderingPath(c.ink.withAlpha(22)),
                        ),
                      ),
                      Center(
                        child: ObjectShowcase(type: journey.type, size: 144),
                      ),
                      Positioned(
                        left: 10,
                        top: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: c.surface.withAlpha(220),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            item.distance == null
                                ? (journey.isSampleData
                                      ? 'PREVIEW'
                                      : 'YOUR CREATION')
                                : '≈ ${item.distance!.round()} km · city-level',
                            style: TextStyle(
                              color: c.ink,
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              letterSpacing: .5,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 4,
                        top: 3,
                        child: IconButton(
                          tooltip: journey.isFollowed
                              ? 'Unsave ${journey.name}'
                              : 'Save ${journey.name}',
                          onPressed: saving ? null : onSave,
                          icon: Icon(
                            journey.isFollowed
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            color: c.ink,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.place_outlined, size: 12, color: c.muted),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
                            style: TextStyle(color: c.muted, fontSize: 10),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (journey.isSampleData && item.distance != null)
                          Text(
                            'Preview',
                            style: TextStyle(fontSize: 9, color: c.muted),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      journey.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: c.ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -.3,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      journey.mission,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: c.muted,
                        fontSize: 11,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'Meet ${journey.type.displayName.toLowerCase()}',
                          style: TextStyle(
                            color: c.ink,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: c.ink,
                          size: 16,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PersonalJourneyCard extends StatelessWidget {
  final JourneyObject journey;
  final List<JourneyStop> stops;
  final VoidCallback onOpen;
  const PersonalJourneyCard({
    required this.journey,
    required this.stops,
    required this.onOpen,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    final c = JourneyColors(context);
    final stats = computeStats(journey.id, stops);
    final progress = journey.goalType == GoalType.countries
        ? stats.countries
        : stats.people;
    return Material(
      color: c.surface,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: c.line),
          ),
          child: Row(
            children: [
              Container(
                width: 76,
                height: 84,
                decoration: BoxDecoration(
                  color: journey.type.accentColor.withAlpha(24),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: ObjectArtworkWidget(type: journey.type, size: 70),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      journey.isSampleData
                          ? 'PREVIEW JOURNEY'
                          : 'STARTED BY YOU',
                      style: TextStyle(
                        color: c.muted,
                        fontSize: 8,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      journey.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: c.ink,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      '${stats.people} people · ${stats.countries} countries',
                      style: TextStyle(fontSize: 10, color: c.muted),
                    ),
                    if (journey.goalTarget != null &&
                        journey.goalTarget! > 0) ...[
                      const SizedBox(height: 9),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (progress / journey.goalTarget!).clamp(0, 1),
                          minHeight: 3,
                          color: JourneyColors.green,
                          backgroundColor: c.sage,
                          semanticsLabel:
                              '$progress of ${journey.goalTarget} ${journey.goalType.name}',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_outward_rounded, size: 18, color: c.ink),
            ],
          ),
        ),
      ),
    );
  }
}
