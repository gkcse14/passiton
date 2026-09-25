import 'package:flutter/material.dart';
import '../../../core/models/journey_models.dart';
import '../../../theme/app_theme.dart';

// Schematic route map — clearly labelled, no GPS dependency
// Draws edges between parent-child stops with city/country centroid positions

class JourneyMapWidget extends StatefulWidget {
  final List<JourneyStop> stops;
  final String journeyId;

  const JourneyMapWidget({
    required this.stops,
    required this.journeyId,
    super.key,
  });

  @override
  State<JourneyMapWidget> createState() => _JourneyMapWidgetState();
}

class _JourneyMapWidgetState extends State<JourneyMapWidget> {
  String? _selectedStopId;

  List<JourneyStop> get _mappableStops =>
      widget.stops.where((s) => s.lat != null && s.lng != null).toList();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_mappableStops.isEmpty) {
      return _buildNoMapState(isDark);
    }

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              // Map canvas
              CustomPaint(
                painter: _SchematicMapPainter(
                  stops: _mappableStops,
                  allStops: widget.stops,
                  selectedStopId: _selectedStopId,
                  isDark: isDark,
                ),
                child: GestureDetector(
                  onTapDown: (details) => _handleTap(details.localPosition),
                  child: Container(color: Colors.transparent),
                ),
              ),
              // Label: schematic note
              Positioned(
                top: 8,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          (isDark
                                  ? AppTheme.surfaceDark
                                  : AppTheme.surfaceLight)
                              .withAlpha(217),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? AppTheme.borderDark
                            : AppTheme.borderLight,
                      ),
                    ),
                    child: Text(
                      'Schematic route — not geographically accurate',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textSecondaryLight,
                      ),
                    ),
                  ),
                ),
              ),
              // Stop detail popup
              if (_selectedStopId != null)
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: _buildStopPopup(isDark, theme),
                ),
            ],
          ),
        ),
        // Accessible list of stops
        _buildStopList(isDark, theme),
      ],
    );
  }

  void _handleTap(Offset position) {
    // Find closest stop marker
    final size = context.size ?? const Size(400, 400);
    final positions = _computePositions(size);
    String? closest;
    double minDist = 30;
    for (final entry in positions.entries) {
      final d = (entry.value - position).distance;
      if (d < minDist) {
        minDist = d;
        closest = entry.key;
      }
    }
    setState(
      () => _selectedStopId = closest == _selectedStopId ? null : closest,
    );
  }

  Map<String, Offset> _computePositions(Size size) {
    if (_mappableStops.isEmpty) return {};
    double minLat = _mappableStops.first.lat!;
    double maxLat = _mappableStops.first.lat!;
    double minLng = _mappableStops.first.lng!;
    double maxLng = _mappableStops.first.lng!;
    for (final s in _mappableStops) {
      if (s.lat! < minLat) minLat = s.lat!;
      if (s.lat! > maxLat) maxLat = s.lat!;
      if (s.lng! < minLng) minLng = s.lng!;
      if (s.lng! > maxLng) maxLng = s.lng!;
    }
    final padding = 48.0;
    final w = size.width - padding * 2;
    final h = size.height - padding * 2;
    final latRange = (maxLat - minLat).abs().clamp(1.0, 180.0);
    final lngRange = (maxLng - minLng).abs().clamp(1.0, 360.0);

    final result = <String, Offset>{};
    for (final s in _mappableStops) {
      final x = padding + ((s.lng! - minLng) / lngRange) * w;
      final y = padding + ((maxLat - s.lat!) / latRange) * h;
      result[s.id] = Offset(x, y);
    }
    return result;
  }

  Widget _buildNoMapState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map_rounded,
            size: 64,
            color: isDark
                ? AppTheme.textSecondaryDark
                : AppTheme.textSecondaryLight,
          ),
          const SizedBox(height: 16),
          Text(
            'No mapped locations yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppTheme.textPrimaryDark
                  : AppTheme.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Stops with hidden or country-only locations\ndon\'t appear on the map.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 16),
          // Still show timeline summary
          _buildStopList(isDark, Theme.of(context)),
        ],
      ),
    );
  }

  Widget _buildStopPopup(bool isDark, ThemeData theme) {
    final stop = widget.stops.firstWhere((s) => s.id == _selectedStopId!);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(38),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primaryContainer,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Text(
                stop.displayName.isNotEmpty
                    ? stop.displayName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stop.displayName, style: theme.textTheme.titleSmall),
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
          ),
          GestureDetector(
            onTap: () => setState(() => _selectedStopId = null),
            child: Icon(
              Icons.close_rounded,
              size: 18,
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStopList(bool isDark, ThemeData theme) {
    final hiddenStops = widget.stops
        .where((s) => s.locationVisibility == LocationVisibility.hidden)
        .toList();
    if (hiddenStops.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.visibility_off_rounded,
                size: 14,
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight,
              ),
              const SizedBox(width: 6),
              Text(
                '${hiddenStops.length} stop${hiddenStops.length > 1 ? 's' : ''} with hidden location',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SchematicMapPainter extends CustomPainter {
  final List<JourneyStop> stops;
  final List<JourneyStop> allStops;
  final String? selectedStopId;
  final bool isDark;

  _SchematicMapPainter({
    required this.stops,
    required this.allStops,
    required this.selectedStopId,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (stops.isEmpty) return;

    final positions = _computePositions(size);

    // Draw edges
    final edgePaint = Paint()
      ..color = AppTheme.primary.withAlpha(89)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final stop in stops) {
      if (stop.parentStopId == null) continue;
      final parentPos = positions[stop.parentStopId];
      final childPos = positions[stop.id];
      if (parentPos == null || childPos == null) continue;

      // Draw curved line
      final path = Path();
      path.moveTo(parentPos.dx, parentPos.dy);
      final mid = Offset(
        (parentPos.dx + childPos.dx) / 2,
        (parentPos.dy + childPos.dy) / 2 - 30,
      );
      path.quadraticBezierTo(mid.dx, mid.dy, childPos.dx, childPos.dy);
      canvas.drawPath(path, edgePaint);

      // Arrow
      _drawArrow(canvas, parentPos, childPos, edgePaint);
    }

    // Draw nodes
    for (final stop in stops) {
      final pos = positions[stop.id];
      if (pos == null) continue;

      final isSelected = stop.id == selectedStopId;
      final isOrigin = stop.isOrigin;

      // Outer glow for selected
      if (isSelected) {
        final glowPaint = Paint()
          ..color = AppTheme.primary.withAlpha(51)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, 20, glowPaint);
      }

      // Node circle
      final nodePaint = Paint()
        ..color = isOrigin
            ? AppTheme.primary
            : (isDark ? AppTheme.surfaceDark : Colors.white)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, isSelected ? 14 : 11, nodePaint);

      final borderPaint = Paint()
        ..color = isOrigin ? AppTheme.primary : AppTheme.primary.withAlpha(153)
        ..strokeWidth = isSelected ? 2.5 : 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(pos, isSelected ? 14 : 11, borderPaint);

      // City label
      if (stop.cityName != null) {
        final tp = TextPainter(
          text: TextSpan(
            text: stop.cityName,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppTheme.textPrimaryDark
                  : AppTheme.textPrimaryLight,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy + 16));
      }
    }
  }

  void _drawArrow(Canvas canvas, Offset from, Offset to, Paint paint) {
    final dir = (to - from);
    final len = dir.distance;
    if (len < 1) return;
    final unit = dir / len;
    final arrowTip = to - unit * 12;
    final perp = Offset(-unit.dy, unit.dx);
    final p1 = arrowTip + perp * 5;
    final p2 = arrowTip - perp * 5;
    final path = Path()
      ..moveTo(to.dx, to.dy)
      ..lineTo(p1.dx, p1.dy)
      ..moveTo(to.dx, to.dy)
      ..lineTo(p2.dx, p2.dy);
    canvas.drawPath(path, paint);
  }

  Map<String, Offset> _computePositions(Size size) {
    if (stops.isEmpty) return {};
    double minLat = stops.first.lat!;
    double maxLat = stops.first.lat!;
    double minLng = stops.first.lng!;
    double maxLng = stops.first.lng!;
    for (final s in stops) {
      if (s.lat! < minLat) minLat = s.lat!;
      if (s.lat! > maxLat) maxLat = s.lat!;
      if (s.lng! < minLng) minLng = s.lng!;
      if (s.lng! > maxLng) maxLng = s.lng!;
    }
    final padding = 56.0;
    final w = size.width - padding * 2;
    final h = size.height - padding * 2;
    final latRange = (maxLat - minLat).abs().clamp(5.0, 180.0);
    final lngRange = (maxLng - minLng).abs().clamp(5.0, 360.0);

    final result = <String, Offset>{};
    for (final s in stops) {
      final x = padding + ((s.lng! - minLng) / lngRange) * w;
      final y = padding + ((maxLat - s.lat!) / latRange) * h;
      result[s.id] = Offset(x, y);
    }
    return result;
  }

  @override
  bool shouldRepaint(_SchematicMapPainter old) =>
      old.selectedStopId != selectedStopId || old.stops.length != stops.length;
}
