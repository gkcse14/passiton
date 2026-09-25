import 'package:flutter/material.dart';
import '../../../core/models/journey_models.dart';
import '../../../theme/app_theme.dart';

// Polished scalable Flutter illustrations for each object type
// Consistent soft dimensional style: rounded forms, gentle highlights

class ObjectArtworkWidget extends StatelessWidget {
  final ObjectType type;
  final double size;

  const ObjectArtworkWidget({
    required this.type,
    required this.size,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _ObjectPainter(type: type)),
    );
  }
}

class _ObjectPainter extends CustomPainter {
  final ObjectType type;
  const _ObjectPainter({required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case ObjectType.potato:
        _drawPotato(canvas, size);
        break;
      case ObjectType.heart:
        _drawHeart(canvas, size);
        break;
      case ObjectType.lotus:
        _drawLotus(canvas, size);
        break;
      case ObjectType.paperPlane:
        _drawPaperPlane(canvas, size);
        break;
      case ObjectType.star:
        _drawStar(canvas, size);
        break;
      case ObjectType.seedling:
        _drawSeedling(canvas, size);
        break;
    }
  }

  void _drawPotato(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Ground shadow
    final shadowPaint = Paint()
      ..color = AppTheme.potatoAccent.withAlpha(46)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + size.height * 0.38),
        width: size.width * 0.55,
        height: size.height * 0.14,
      ),
      shadowPaint,
    );

    // Body gradient
    final bodyPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        radius: 0.8,
        colors: [
          const Color(0xFFE8C87A),
          AppTheme.potatoAccent,
          const Color(0xFFB8923A),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Potato body shape
    final path = Path();
    path.moveTo(cx - size.width * 0.28, cy + size.height * 0.05);
    path.cubicTo(
      cx - size.width * 0.35,
      cy - size.height * 0.22,
      cx - size.width * 0.10,
      cy - size.height * 0.38,
      cx + size.width * 0.04,
      cy - size.height * 0.35,
    );
    path.cubicTo(
      cx + size.width * 0.22,
      cy - size.height * 0.32,
      cx + size.width * 0.36,
      cy - size.height * 0.10,
      cx + size.width * 0.30,
      cy + size.height * 0.12,
    );
    path.cubicTo(
      cx + size.width * 0.24,
      cy + size.height * 0.32,
      cx + size.width * 0.00,
      cy + size.height * 0.38,
      cx - size.width * 0.14,
      cy + size.height * 0.32,
    );
    path.cubicTo(
      cx - size.width * 0.30,
      cy + size.height * 0.26,
      cx - size.width * 0.34,
      cy + size.height * 0.14,
      cx - size.width * 0.28,
      cy + size.height * 0.05,
    );
    path.close();
    canvas.drawPath(path, bodyPaint);

    // Highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withAlpha(89)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - size.width * 0.08, cy - size.height * 0.18),
        width: size.width * 0.22,
        height: size.height * 0.14,
      ),
      highlightPaint,
    );

    // Eyes
    final eyePaint = Paint()..color = const Color(0xFF5A3A1A);
    canvas.drawCircle(
      Offset(cx - size.width * 0.10, cy - size.height * 0.06),
      size.width * 0.045,
      eyePaint,
    );
    canvas.drawCircle(
      Offset(cx + size.width * 0.08, cy - size.height * 0.08),
      size.width * 0.038,
      eyePaint,
    );

    // Eye shine
    final shinePaint = Paint()..color = Colors.white;
    canvas.drawCircle(
      Offset(cx - size.width * 0.085, cy - size.height * 0.078),
      size.width * 0.016,
      shinePaint,
    );
    canvas.drawCircle(
      Offset(cx + size.width * 0.096, cy - size.height * 0.098),
      size.width * 0.013,
      shinePaint,
    );

    // Smile
    final smilePaint = Paint()
      ..color = const Color(0xFF5A3A1A)
      ..strokeWidth = size.width * 0.028
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final smilePath = Path();
    smilePath.moveTo(cx - size.width * 0.09, cy + size.height * 0.08);
    smilePath.quadraticBezierTo(
      cx,
      cy + size.height * 0.17,
      cx + size.width * 0.09,
      cy + size.height * 0.06,
    );
    canvas.drawPath(smilePath, smilePaint);

    // Sprout
    final sproutPaint = Paint()
      ..color = AppTheme.seedlingAccent
      ..strokeWidth = size.width * 0.025
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final sproutPath = Path();
    sproutPath.moveTo(cx + size.width * 0.04, cy - size.height * 0.35);
    sproutPath.cubicTo(
      cx + size.width * 0.04,
      cy - size.height * 0.52,
      cx + size.width * 0.18,
      cy - size.height * 0.50,
      cx + size.width * 0.18,
      cy - size.height * 0.42,
    );
    canvas.drawPath(sproutPath, sproutPaint);
  }

  void _drawHeart(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final shadowPaint = Paint()
      ..color = AppTheme.heartAccent.withAlpha(51)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + size.height * 0.36),
        width: size.width * 0.5,
        height: size.height * 0.12,
      ),
      shadowPaint,
    );

    final heartPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFFF9999),
          AppTheme.heartAccent,
          const Color(0xFFCC4444),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final w = size.width * 0.72;
    final h = size.height * 0.65;
    final x = cx - w / 2;
    final y = cy - h * 0.38;
    path.moveTo(cx, y + h * 0.32);
    path.cubicTo(cx, y, x, y, x, y + h * 0.32);
    path.cubicTo(x, y + h * 0.65, cx - w * 0.05, y + h * 0.80, cx, y + h);
    path.cubicTo(
      cx + w * 0.05,
      y + h * 0.80,
      x + w,
      y + h * 0.65,
      x + w,
      y + h * 0.32,
    );
    path.cubicTo(x + w, y, cx, y, cx, y + h * 0.32);
    path.close();
    canvas.drawPath(path, heartPaint);

    final hlPaint = Paint()
      ..color = Colors.white.withAlpha(102)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - size.width * 0.10, cy - size.height * 0.10),
        width: size.width * 0.18,
        height: size.height * 0.12,
      ),
      hlPaint,
    );
  }

  void _drawLotus(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + size.height * 0.04;

    final shadowPaint = Paint()
      ..color = AppTheme.lotusAccent.withAlpha(46)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + size.height * 0.34),
        width: size.width * 0.55,
        height: size.height * 0.12,
      ),
      shadowPaint,
    );

    // Petals
    final petalColors = [
      const Color(0xFFE8B4D8),
      AppTheme.lotusAccent,
      const Color(0xFF8A4FA8),
    ];
    final petalPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [petalColors[0], petalColors[1]],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Draw 5 petals
    for (int i = 0; i < 5; i++) {
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate((i * 72) * 3.14159 / 180);
      final petalPath = Path();
      petalPath.moveTo(0, 0);
      petalPath.cubicTo(
        -size.width * 0.12,
        -size.height * 0.10,
        -size.width * 0.10,
        -size.height * 0.38,
        0,
        -size.height * 0.42,
      );
      petalPath.cubicTo(
        size.width * 0.10,
        -size.height * 0.38,
        size.width * 0.12,
        -size.height * 0.10,
        0,
        0,
      );
      petalPath.close();
      canvas.drawPath(petalPath, petalPaint);
      canvas.restore();
    }

    // Center
    final centerPaint = Paint()..color = const Color(0xFFFFE066);
    canvas.drawCircle(Offset(cx, cy), size.width * 0.12, centerPaint);
    final centerHL = Paint()..color = Colors.white.withAlpha(128);
    canvas.drawCircle(
      Offset(cx - size.width * 0.04, cy - size.height * 0.04),
      size.width * 0.05,
      centerHL,
    );
  }

  void _drawPaperPlane(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final shadowPaint = Paint()
      ..color = AppTheme.paperPlaneAccent.withAlpha(46)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + size.width * 0.04, cy + size.height * 0.38),
        width: size.width * 0.5,
        height: size.height * 0.10,
      ),
      shadowPaint,
    );

    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF8BBFE8),
          AppTheme.paperPlaneAccent,
          const Color(0xFF2A6BAD),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Main body
    final bodyPath = Path();
    bodyPath.moveTo(cx + size.width * 0.38, cy);
    bodyPath.lineTo(cx - size.width * 0.38, cy - size.height * 0.28);
    bodyPath.lineTo(cx - size.width * 0.12, cy);
    bodyPath.lineTo(cx - size.width * 0.38, cy + size.height * 0.22);
    bodyPath.close();
    canvas.drawPath(bodyPath, bodyPaint);

    // Fold line
    final foldPaint = Paint()
      ..color = Colors.white.withAlpha(128)
      ..strokeWidth = size.width * 0.02
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(cx + size.width * 0.38, cy),
      Offset(cx - size.width * 0.12, cy),
      foldPaint,
    );
  }

  void _drawStar(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final shadowPaint = Paint()
      ..color = AppTheme.starAccent.withAlpha(51)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + size.height * 0.38),
        width: size.width * 0.5,
        height: size.height * 0.12,
      ),
      shadowPaint,
    );

    final starPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.2, -0.3),
        radius: 0.7,
        colors: [
          const Color(0xFFFFF0A0),
          AppTheme.starAccent,
          const Color(0xFFD4A000),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    const points = 5;
    final outer = size.width * 0.40;
    final inner = size.width * 0.18;
    for (int i = 0; i < points * 2; i++) {
      final angle = (i * 3.14159 / points) - 3.14159 / 2;
      final r = i.isEven ? outer : inner;
      final x = cx + r * _cos(angle);
      final y = cy + r * _sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, starPaint);

    final hlPaint = Paint()
      ..color = Colors.white.withAlpha(128)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(
      Offset(cx - size.width * 0.06, cy - size.height * 0.12),
      size.width * 0.08,
      hlPaint,
    );
  }

  void _drawSeedling(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.58;

    final shadowPaint = Paint()
      ..color = AppTheme.seedlingAccent.withAlpha(38)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + size.height * 0.25),
        width: size.width * 0.45,
        height: size.height * 0.10,
      ),
      shadowPaint,
    );

    // Stem
    final stemPaint = Paint()
      ..color = const Color(0xFF4A8A3A)
      ..strokeWidth = size.width * 0.055
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(cx, cy + size.height * 0.22),
      Offset(cx, cy - size.height * 0.22),
      stemPaint,
    );

    // Left leaf
    final leafPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF80D080),
          AppTheme.seedlingAccent,
          const Color(0xFF2A7A3A),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    final leftLeaf = Path();
    leftLeaf.moveTo(cx, cy - size.height * 0.04);
    leftLeaf.cubicTo(
      cx - size.width * 0.04,
      cy - size.height * 0.18,
      cx - size.width * 0.28,
      cy - size.height * 0.20,
      cx - size.width * 0.30,
      cy - size.height * 0.10,
    );
    leftLeaf.cubicTo(
      cx - size.width * 0.28,
      cy - size.height * 0.00,
      cx - size.width * 0.04,
      cy + size.height * 0.02,
      cx,
      cy - size.height * 0.04,
    );
    leftLeaf.close();
    canvas.drawPath(leftLeaf, leafPaint);

    // Right leaf
    final rightLeaf = Path();
    rightLeaf.moveTo(cx, cy - size.height * 0.12);
    rightLeaf.cubicTo(
      cx + size.width * 0.04,
      cy - size.height * 0.26,
      cx + size.width * 0.28,
      cy - size.height * 0.28,
      cx + size.width * 0.30,
      cy - size.height * 0.18,
    );
    rightLeaf.cubicTo(
      cx + size.width * 0.28,
      cy - size.height * 0.08,
      cx + size.width * 0.04,
      cy - size.height * 0.06,
      cx,
      cy - size.height * 0.12,
    );
    rightLeaf.close();
    canvas.drawPath(rightLeaf, leafPaint);

    // Soil mound
    final soilPaint = Paint()..color = const Color(0xFFB8824A);
    final soilPath = Path();
    soilPath.moveTo(cx - size.width * 0.28, cy + size.height * 0.24);
    soilPath.quadraticBezierTo(
      cx,
      cy + size.height * 0.14,
      cx + size.width * 0.28,
      cy + size.height * 0.24,
    );
    soilPath.close();
    canvas.drawPath(soilPath, soilPaint);
  }

  double _cos(double x) => 1 - x * x / 2 + x * x * x * x / 24;
  double _sin(double x) => x - x * x * x / 6 + x * x * x * x * x / 120;

  @override
  bool shouldRepaint(_ObjectPainter oldDelegate) => oldDelegate.type != type;
}
