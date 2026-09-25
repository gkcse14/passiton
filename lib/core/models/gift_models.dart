import 'package:flutter/material.dart';

// ─── Catalogue ────────────────────────────────────────────────────────────────

enum GiftSource { free, demoPaid, seededDemo }

class GiftCatalogItem {
  final String id;
  final String name;
  final String description;
  final bool isFree;

  /// Price in integer minor units (paise). 0 for free.
  final int demoPriceMinorUnits;
  final String currencyCode;
  final int sortOrder;
  final bool isActive;

  const GiftCatalogItem({
    required this.id,
    required this.name,
    required this.description,
    required this.isFree,
    required this.demoPriceMinorUnits,
    this.currencyCode = 'INR',
    required this.sortOrder,
    this.isActive = true,
  });

  String get formattedPrice {
    if (isFree) return 'Free';
    final rupees = demoPriceMinorUnits ~/ 100;
    return '₹$rupees';
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'description': description,
    'isFree': isFree,
    'demoPriceMinorUnits': demoPriceMinorUnits,
    'currencyCode': currencyCode,
    'sortOrder': sortOrder,
    'isActive': isActive,
  };

  factory GiftCatalogItem.fromMap(Map<String, dynamic> m) => GiftCatalogItem(
    id: m['id'] as String,
    name: m['name'] as String,
    description: m['description'] as String,
    isFree: m['isFree'] as bool,
    demoPriceMinorUnits: m['demoPriceMinorUnits'] as int,
    currencyCode: m['currencyCode'] as String? ?? 'INR',
    sortOrder: m['sortOrder'] as int,
    isActive: m['isActive'] as bool? ?? true,
  );
}

// ─── Contribution ─────────────────────────────────────────────────────────────

class GiftContribution {
  final String id;
  final String objectId;
  final String senderParticipantId;
  final String senderDisplayName;
  final String? senderStopId;
  final String catalogueGiftId;
  final String? message;
  final DateTime createdAt;
  final GiftSource source;

  /// Snapshot of price at time of demo purchase (minor units). Null for free.
  final int? pricePaidMinorUnits;
  final String? currencySnapshot;

  const GiftContribution({
    required this.id,
    required this.objectId,
    required this.senderParticipantId,
    required this.senderDisplayName,
    this.senderStopId,
    required this.catalogueGiftId,
    this.message,
    required this.createdAt,
    required this.source,
    this.pricePaidMinorUnits,
    this.currencySnapshot,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'objectId': objectId,
    'senderParticipantId': senderParticipantId,
    'senderDisplayName': senderDisplayName,
    'senderStopId': senderStopId,
    'catalogueGiftId': catalogueGiftId,
    'message': message,
    'createdAt': createdAt.toIso8601String(),
    'source': source.name,
    'pricePaidMinorUnits': pricePaidMinorUnits,
    'currencySnapshot': currencySnapshot,
  };

  factory GiftContribution.fromMap(Map<String, dynamic> m) => GiftContribution(
    id: m['id'] as String,
    objectId: m['objectId'] as String,
    senderParticipantId: m['senderParticipantId'] as String,
    senderDisplayName: m['senderDisplayName'] as String,
    senderStopId: m['senderStopId'] as String?,
    catalogueGiftId: m['catalogueGiftId'] as String,
    message: m['message'] as String?,
    createdAt: DateTime.parse(m['createdAt'] as String),
    source: _sourceFromString(m['source'] as String),
    pricePaidMinorUnits: m['pricePaidMinorUnits'] as int?,
    currencySnapshot: m['currencySnapshot'] as String?,
  );

  static GiftSource _sourceFromString(String s) {
    switch (s) {
      case 'demoPaid':
        return GiftSource.demoPaid;
      case 'seededDemo':
        return GiftSource.seededDemo;
      default:
        return GiftSource.free;
    }
  }
}

// ─── Grouped view model ───────────────────────────────────────────────────────

class GiftGroupedItem {
  final GiftCatalogItem catalogItem;
  final int totalCount;
  final DateTime mostRecentDate;
  final List<GiftContribution> contributions;

  const GiftGroupedItem({
    required this.catalogItem,
    required this.totalCount,
    required this.mostRecentDate,
    required this.contributions,
  });
}

// ─── Supporter view model ─────────────────────────────────────────────────────

class GiftSupporter {
  final String participantId;
  final String displayName;
  final int giftCount;
  final List<GiftCatalogItem> giftedItems;
  final DateTime mostRecentAt;

  const GiftSupporter({
    required this.participantId,
    required this.displayName,
    required this.giftCount,
    required this.giftedItems,
    required this.mostRecentAt,
  });
}

// ─── Journey gift summary (for cards) ─────────────────────────────────────────

class JourneyGiftSummary {
  final String objectId;
  final int totalGifts;
  final int distinctSupporters;
  final List<GiftCatalogItem> previewItems; // up to 4

  const JourneyGiftSummary({
    required this.objectId,
    required this.totalGifts,
    required this.distinctSupporters,
    required this.previewItems,
  });
}

// ─── Gift artwork painter ─────────────────────────────────────────────────────

class GiftArtworkPainter extends CustomPainter {
  final String giftId;
  final Color primaryColor;
  final Color accentColor;

  GiftArtworkPainter({
    required this.giftId,
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.38;

    switch (giftId) {
      case 'gift-01': // Little Heart
        _paintHeart(canvas, size, cx, cy, r);
        break;
      case 'gift-02': // Good Luck Clover
        _paintClover(canvas, size, cx, cy, r);
        break;
      case 'gift-03': // Rose
        _paintRose(canvas, size, cx, cy, r);
        break;
      case 'gift-04': // Coffee
        _paintCoffee(canvas, size, cx, cy, r);
        break;
      case 'gift-05': // Balloon
        _paintBalloon(canvas, size, cx, cy, r);
        break;
      case 'gift-06': // Cupcake
        _paintCupcake(canvas, size, cx, cy, r);
        break;
      case 'gift-07': // Lucky Star
        _paintStar(canvas, size, cx, cy, r);
        break;
      case 'gift-08': // Tiny Plant
        _paintPlant(canvas, size, cx, cy, r);
        break;
      case 'gift-09': // Teddy Bear
        _paintTeddy(canvas, size, cx, cy, r);
        break;
      case 'gift-10': // Gift Box
        _paintGiftBox(canvas, size, cx, cy, r);
        break;
      case 'gift-11': // Birthday Cake
        _paintCake(canvas, size, cx, cy, r);
        break;
      case 'gift-12': // Flower Bouquet
        _paintBouquet(canvas, size, cx, cy, r);
        break;
      case 'gift-13': // Crown
        _paintCrown(canvas, size, cx, cy, r);
        break;
      case 'gift-14': // Hot Air Balloon
        _paintHotAirBalloon(canvas, size, cx, cy, r);
        break;
      case 'gift-15': // Rocket
        _paintRocket(canvas, size, cx, cy, r);
        break;
      case 'gift-16': // Treasure Chest
        _paintChest(canvas, size, cx, cy, r);
        break;
      case 'gift-17': // Rainbow
        _paintRainbow(canvas, size, cx, cy, r);
        break;
      case 'gift-18': // Castle
        _paintCastle(canvas, size, cx, cy, r);
        break;
      case 'gift-19': // Planet
        _paintPlanet(canvas, size, cx, cy, r);
        break;
      case 'gift-20': // Galaxy Globe
        _paintGalaxyGlobe(canvas, size, cx, cy, r);
        break;
      default:
        _paintHeart(canvas, size, cx, cy, r);
    }
  }

  // ── Heart ──
  void _paintHeart(Canvas canvas, Size size, double cx, double cy, double r) {
    final p = Paint()..color = const Color(0xFFE87070);
    final ps = Paint()..color = const Color(0xFFFFB3B3);
    final path = Path();
    final s = r * 0.9;
    path.moveTo(cx, cy + s * 0.5);
    path.cubicTo(
      cx - s * 1.2,
      cy - s * 0.2,
      cx - s * 1.2,
      cy - s * 1.0,
      cx,
      cy - s * 0.3,
    );
    path.cubicTo(
      cx + s * 1.2,
      cy - s * 1.0,
      cx + s * 1.2,
      cy - s * 0.2,
      cx,
      cy + s * 0.5,
    );
    canvas.drawPath(path, p);
    // highlight
    canvas.drawCircle(
      Offset(cx - s * 0.3, cy - s * 0.1),
      s * 0.2,
      ps..color = const Color(0xFFFFD0D0),
    );
  }

  // ── Clover ──
  void _paintClover(Canvas canvas, Size size, double cx, double cy, double r) {
    final p = Paint()..color = const Color(0xFF4CAF50);
    final ps = Paint()..color = const Color(0xFF81C784);
    final leafR = r * 0.5;
    // 4 leaves
    for (int i = 0; i < 4; i++) {
      final angle = i * 3.14159 / 2;
      final lx = cx + leafR * 0.6 * _cos(angle);
      final ly = cy + leafR * 0.6 * _sin(angle);
      canvas.drawCircle(Offset(lx, ly), leafR, p);
    }
    // highlights
    for (int i = 0; i < 4; i++) {
      final angle = i * 3.14159 / 2 - 0.4;
      final lx = cx + leafR * 0.6 * _cos(angle);
      final ly = cy + leafR * 0.6 * _sin(angle);
      canvas.drawCircle(
        Offset(lx - leafR * 0.15, ly - leafR * 0.15),
        leafR * 0.25,
        ps,
      );
    }
    // stem
    final stemPaint = Paint()
      ..color = const Color(0xFF388E3C)
      ..strokeWidth = r * 0.12
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx, cy + leafR * 0.3),
      Offset(cx, cy + r * 0.9),
      stemPaint,
    );
  }

  // ── Rose ──
  void _paintRose(Canvas canvas, Size size, double cx, double cy, double r) {
    final p = Paint()..color = const Color(0xFFE53935);
    final ps = Paint()..color = const Color(0xFFEF9A9A);
    // petals
    for (int i = 0; i < 5; i++) {
      final angle = i * 2 * 3.14159 / 5;
      final px = cx + r * 0.45 * _cos(angle);
      final py = cy + r * 0.45 * _sin(angle);
      canvas.drawCircle(Offset(px, py), r * 0.38, p);
    }
    canvas.drawCircle(Offset(cx, cy), r * 0.35, p);
    canvas.drawCircle(Offset(cx - r * 0.1, cy - r * 0.1), r * 0.15, ps);
    // stem
    final stemPaint = Paint()
      ..color = const Color(0xFF388E3C)
      ..strokeWidth = r * 0.12
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx, cy + r * 0.5),
      Offset(cx, cy + r * 1.1),
      stemPaint,
    );
  }

  // ── Coffee ──
  void _paintCoffee(Canvas canvas, Size size, double cx, double cy, double r) {
    final cupPaint = Paint()..color = const Color(0xFFFFB74D);
    final coffeePaint = Paint()..color = const Color(0xFF6D4C41);
    final steamPaint = Paint()
      ..color = const Color(0xFFB0BEC5)
      ..strokeWidth = r * 0.1
      ..strokeCap = StrokeCap.round;
    // cup body
    final cupRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, cy + r * 0.2),
        width: r * 1.4,
        height: r * 1.1,
      ),
      Radius.circular(r * 0.2),
    );
    canvas.drawRRect(cupRect, cupPaint);
    // coffee fill
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, cy + r * 0.15),
          width: r * 1.2,
          height: r * 0.5,
        ),
        Radius.circular(r * 0.15),
      ),
      coffeePaint,
    );
    // handle
    final handlePaint = Paint()
      ..color = const Color(0xFFFF8F00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.12;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(cx + r * 0.75, cy + r * 0.2),
        width: r * 0.5,
        height: r * 0.5,
      ),
      -1.57,
      3.14,
      false,
      handlePaint,
    );
    // steam
    canvas.drawLine(
      Offset(cx - r * 0.2, cy - r * 0.2),
      Offset(cx - r * 0.3, cy - r * 0.6),
      steamPaint,
    );
    canvas.drawLine(
      Offset(cx + r * 0.2, cy - r * 0.2),
      Offset(cx + r * 0.1, cy - r * 0.6),
      steamPaint,
    );
  }

  // ── Balloon ──
  void _paintBalloon(Canvas canvas, Size size, double cx, double cy, double r) {
    final p = Paint()..color = const Color(0xFF7C4DFF);
    final ps = Paint()..color = const Color(0xFFB39DDB);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy - r * 0.1),
        width: r * 1.6,
        height: r * 1.8,
      ),
      p,
    );
    canvas.drawCircle(Offset(cx - r * 0.35, cy - r * 0.45), r * 0.25, ps);
    // knot
    final knotPaint = Paint()..color = const Color(0xFF5E35B1);
    canvas.drawCircle(Offset(cx, cy + r * 0.8), r * 0.1, knotPaint);
    // string
    final stringPaint = Paint()
      ..color = const Color(0xFF9E9E9E)
      ..strokeWidth = r * 0.06
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx, cy + r * 0.9),
      Offset(cx + r * 0.2, cy + r * 1.3),
      stringPaint,
    );
  }

  // ── Cupcake ──
  void _paintCupcake(Canvas canvas, Size size, double cx, double cy, double r) {
    final wrapPaint = Paint()..color = const Color(0xFFFF8A65);
    final cakePaint = Paint()..color = const Color(0xFFFFCC80);
    final frostPaint = Paint()..color = const Color(0xFFF8BBD9);
    // wrapper
    final wrapPath = Path();
    wrapPath.moveTo(cx - r * 0.6, cy + r * 0.2);
    wrapPath.lineTo(cx - r * 0.5, cy + r * 0.9);
    wrapPath.lineTo(cx + r * 0.5, cy + r * 0.9);
    wrapPath.lineTo(cx + r * 0.6, cy + r * 0.2);
    wrapPath.close();
    canvas.drawPath(wrapPath, wrapPaint);
    // cake body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, cy + r * 0.05),
          width: r * 1.1,
          height: r * 0.5,
        ),
        Radius.circular(r * 0.1),
      ),
      cakePaint,
    );
    // frosting
    final frostPath = Path();
    frostPath.moveTo(cx - r * 0.55, cy - r * 0.2);
    frostPath.quadraticBezierTo(cx - r * 0.3, cy - r * 0.8, cx, cy - r * 0.7);
    frostPath.quadraticBezierTo(
      cx + r * 0.3,
      cy - r * 0.8,
      cx + r * 0.55,
      cy - r * 0.2,
    );
    frostPath.close();
    canvas.drawPath(frostPath, frostPaint);
    // cherry
    canvas.drawCircle(
      Offset(cx, cy - r * 0.75),
      r * 0.12,
      Paint()..color = const Color(0xFFE53935),
    );
  }

  // ── Star ──
  void _paintStar(Canvas canvas, Size size, double cx, double cy, double r) {
    final p = Paint()..color = const Color(0xFFFFD600);
    final ps = Paint()..color = const Color(0xFFFFF176);
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final outerAngle = i * 2 * 3.14159 / 5 - 3.14159 / 2;
      final innerAngle = outerAngle + 3.14159 / 5;
      if (i == 0) {
        path.moveTo(cx + r * _cos(outerAngle), cy + r * _sin(outerAngle));
      } else {
        path.lineTo(cx + r * _cos(outerAngle), cy + r * _sin(outerAngle));
      }
      path.lineTo(
        cx + r * 0.4 * _cos(innerAngle),
        cy + r * 0.4 * _sin(innerAngle),
      );
    }
    path.close();
    canvas.drawPath(path, p);
    canvas.drawCircle(Offset(cx - r * 0.2, cy - r * 0.2), r * 0.15, ps);
  }

  // ── Tiny Plant ──
  void _paintPlant(Canvas canvas, Size size, double cx, double cy, double r) {
    final potPaint = Paint()..color = const Color(0xFFBF8C6A);
    final soilPaint = Paint()..color = const Color(0xFF795548);
    final leafPaint = Paint()..color = const Color(0xFF4CAF50);
    final stemPaint = Paint()
      ..color = const Color(0xFF388E3C)
      ..strokeWidth = r * 0.1
      ..strokeCap = StrokeCap.round;
    // pot
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, cy + r * 0.55),
          width: r * 1.1,
          height: r * 0.8,
        ),
        Radius.circular(r * 0.15),
      ),
      potPaint,
    );
    // soil
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, cy + r * 0.18),
          width: r * 1.1,
          height: r * 0.2,
        ),
        Radius.circular(r * 0.1),
      ),
      soilPaint,
    );
    // stem
    canvas.drawLine(
      Offset(cx, cy + r * 0.15),
      Offset(cx, cy - r * 0.5),
      stemPaint,
    );
    // leaves
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - r * 0.35, cy - r * 0.3),
        width: r * 0.6,
        height: r * 0.35,
      ),
      leafPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + r * 0.35, cy - r * 0.5),
        width: r * 0.6,
        height: r * 0.35,
      ),
      leafPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy - r * 0.7),
        width: r * 0.5,
        height: r * 0.3,
      ),
      leafPaint,
    );
  }

  // ── Teddy Bear ──
  void _paintTeddy(Canvas canvas, Size size, double cx, double cy, double r) {
    final p = Paint()..color = const Color(0xFFD4A853);
    final ps = Paint()..color = const Color(0xFFE8C97A);
    final dark = Paint()..color = const Color(0xFF8B6914);
    // ears
    canvas.drawCircle(Offset(cx - r * 0.5, cy - r * 0.6), r * 0.3, p);
    canvas.drawCircle(Offset(cx + r * 0.5, cy - r * 0.6), r * 0.3, p);
    canvas.drawCircle(Offset(cx - r * 0.5, cy - r * 0.6), r * 0.18, ps);
    canvas.drawCircle(Offset(cx + r * 0.5, cy - r * 0.6), r * 0.18, ps);
    // head
    canvas.drawCircle(Offset(cx, cy - r * 0.15), r * 0.65, p);
    // snout
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + r * 0.15),
        width: r * 0.55,
        height: r * 0.35,
      ),
      ps,
    );
    // eyes
    canvas.drawCircle(Offset(cx - r * 0.22, cy - r * 0.2), r * 0.1, dark);
    canvas.drawCircle(Offset(cx + r * 0.22, cy - r * 0.2), r * 0.1, dark);
    // nose
    canvas.drawCircle(Offset(cx, cy + r * 0.08), r * 0.08, dark);
    // body
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + r * 0.75),
        width: r * 1.0,
        height: r * 0.7,
      ),
      p,
    );
  }

  // ── Gift Box ──
  void _paintGiftBox(Canvas canvas, Size size, double cx, double cy, double r) {
    final boxPaint = Paint()..color = const Color(0xFF1565C0);
    final lidPaint = Paint()..color = const Color(0xFF1976D2);
    final ribbonPaint = Paint()
      ..color = const Color(0xFFFFD600)
      ..strokeWidth = r * 0.14;
    // box
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, cy + r * 0.3),
          width: r * 1.5,
          height: r * 1.0,
        ),
        Radius.circular(r * 0.12),
      ),
      boxPaint,
    );
    // lid
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, cy - r * 0.25),
          width: r * 1.6,
          height: r * 0.35,
        ),
        Radius.circular(r * 0.1),
      ),
      lidPaint,
    );
    // ribbon vertical
    canvas.drawLine(
      Offset(cx, cy - r * 0.42),
      Offset(cx, cy + r * 0.8),
      ribbonPaint,
    );
    // ribbon horizontal
    canvas.drawLine(
      Offset(cx - r * 0.75, cy - r * 0.25),
      Offset(cx + r * 0.75, cy - r * 0.25),
      ribbonPaint,
    );
    // bow
    final bowPaint = Paint()..color = const Color(0xFFFFD600);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - r * 0.25, cy - r * 0.5),
        width: r * 0.4,
        height: r * 0.25,
      ),
      bowPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + r * 0.25, cy - r * 0.5),
        width: r * 0.4,
        height: r * 0.25,
      ),
      bowPaint,
    );
    canvas.drawCircle(Offset(cx, cy - r * 0.5), r * 0.12, bowPaint);
  }

  // ── Birthday Cake ──
  void _paintCake(Canvas canvas, Size size, double cx, double cy, double r) {
    final cakePaint = Paint()..color = const Color(0xFFFFCC80);
    final frostPaint = Paint()..color = const Color(0xFFF8BBD9);
    final candlePaint = Paint()..color = const Color(0xFF7C4DFF);
    final flamePaint = Paint()..color = const Color(0xFFFF6D00);
    // cake layers
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, cy + r * 0.5),
          width: r * 1.6,
          height: r * 0.5,
        ),
        Radius.circular(r * 0.1),
      ),
      cakePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, cy + r * 0.05),
          width: r * 1.3,
          height: r * 0.45,
        ),
        Radius.circular(r * 0.1),
      ),
      cakePaint,
    );
    // frosting drips
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, cy - r * 0.18),
          width: r * 1.3,
          height: r * 0.15,
        ),
        Radius.circular(r * 0.07),
      ),
      frostPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, cy + r * 0.28),
          width: r * 1.6,
          height: r * 0.15,
        ),
        Radius.circular(r * 0.07),
      ),
      frostPaint,
    );
    // candles
    for (int i = -1; i <= 1; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx + i * r * 0.4, cy - r * 0.45),
            width: r * 0.12,
            height: r * 0.35,
          ),
          Radius.circular(r * 0.06),
        ),
        candlePaint,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx + i * r * 0.4, cy - r * 0.65),
          width: r * 0.12,
          height: r * 0.18,
        ),
        flamePaint,
      );
    }
  }

  // ── Flower Bouquet ──
  void _paintBouquet(Canvas canvas, Size size, double cx, double cy, double r) {
    final wrapPaint = Paint()..color = const Color(0xFFFFB74D);
    final stemPaint = Paint()
      ..color = const Color(0xFF388E3C)
      ..strokeWidth = r * 0.1
      ..strokeCap = StrokeCap.round;
    final colors = [
      const Color(0xFFE53935),
      const Color(0xFFFFD600),
      const Color(0xFF7C4DFF),
      const Color(0xFFFF8A65),
      const Color(0xFF4CAF50),
    ];
    // stems
    for (int i = -2; i <= 2; i++) {
      canvas.drawLine(
        Offset(cx + i * r * 0.2, cy + r * 0.3),
        Offset(cx + i * r * 0.15, cy - r * 0.2),
        stemPaint,
      );
    }
    // flowers
    final positions = [
      Offset(cx, cy - r * 0.5),
      Offset(cx - r * 0.4, cy - r * 0.3),
      Offset(cx + r * 0.4, cy - r * 0.3),
      Offset(cx - r * 0.2, cy - r * 0.7),
      Offset(cx + r * 0.2, cy - r * 0.7),
    ];
    for (int i = 0; i < positions.length; i++) {
      canvas.drawCircle(
        positions[i],
        r * 0.22,
        Paint()..color = colors[i % colors.length],
      );
      canvas.drawCircle(
        positions[i],
        r * 0.1,
        Paint()..color = const Color(0xFFFFFF00),
      );
    }
    // wrap
    final wrapPath = Path();
    wrapPath.moveTo(cx - r * 0.5, cy + r * 0.3);
    wrapPath.lineTo(cx - r * 0.35, cy + r * 0.9);
    wrapPath.lineTo(cx + r * 0.35, cy + r * 0.9);
    wrapPath.lineTo(cx + r * 0.5, cy + r * 0.3);
    wrapPath.close();
    canvas.drawPath(wrapPath, wrapPaint);
  }

  // ── Crown ──
  void _paintCrown(Canvas canvas, Size size, double cx, double cy, double r) {
    final p = Paint()..color = const Color(0xFFFFD600);
    final ps = Paint()..color = const Color(0xFFFFF176);
    final gemPaint = Paint()..color = const Color(0xFFE53935);
    final path = Path();
    path.moveTo(cx - r * 0.8, cy + r * 0.4);
    path.lineTo(cx - r * 0.8, cy - r * 0.2);
    path.lineTo(cx - r * 0.4, cy - r * 0.7);
    path.lineTo(cx, cy - r * 0.2);
    path.lineTo(cx + r * 0.4, cy - r * 0.7);
    path.lineTo(cx + r * 0.8, cy - r * 0.2);
    path.lineTo(cx + r * 0.8, cy + r * 0.4);
    path.close();
    canvas.drawPath(path, p);
    // band
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, cy + r * 0.25),
          width: r * 1.6,
          height: r * 0.3,
        ),
        Radius.circular(r * 0.08),
      ),
      ps,
    );
    // gems
    canvas.drawCircle(Offset(cx, cy + r * 0.25), r * 0.12, gemPaint);
    canvas.drawCircle(
      Offset(cx - r * 0.5, cy + r * 0.25),
      r * 0.09,
      Paint()..color = const Color(0xFF1565C0),
    );
    canvas.drawCircle(
      Offset(cx + r * 0.5, cy + r * 0.25),
      r * 0.09,
      Paint()..color = const Color(0xFF4CAF50),
    );
  }

  // ── Hot Air Balloon ──
  void _paintHotAirBalloon(
    Canvas canvas,
    Size size,
    double cx,
    double cy,
    double r,
  ) {
    final colors = [
      const Color(0xFFE53935),
      const Color(0xFFFFD600),
      const Color(0xFF1565C0),
      const Color(0xFF4CAF50),
    ];
    // balloon
    for (int i = 0; i < 4; i++) {
      final startAngle = i * 3.14159 / 2 - 3.14159 / 2;
      final sweepAngle = 3.14159 / 2;
      final path = Path();
      path.moveTo(cx, cy - r * 0.1);
      path.arcTo(
        Rect.fromCenter(
          center: Offset(cx, cy - r * 0.1),
          width: r * 1.6,
          height: r * 1.8,
        ),
        startAngle,
        sweepAngle,
        false,
      );
      path.close();
      canvas.drawPath(path, Paint()..color = colors[i]);
    }
    // basket
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, cy + r * 0.85),
          width: r * 0.6,
          height: r * 0.35,
        ),
        Radius.circular(r * 0.08),
      ),
      Paint()..color = const Color(0xFFBF8C6A),
    );
    // ropes
    final ropePaint = Paint()
      ..color = const Color(0xFF795548)
      ..strokeWidth = r * 0.06;
    canvas.drawLine(
      Offset(cx - r * 0.3, cy + r * 0.68),
      Offset(cx - r * 0.25, cy + r * 0.68),
      ropePaint,
    );
    canvas.drawLine(
      Offset(cx + r * 0.3, cy + r * 0.68),
      Offset(cx + r * 0.25, cy + r * 0.68),
      ropePaint,
    );
  }

  // ── Rocket ──
  void _paintRocket(Canvas canvas, Size size, double cx, double cy, double r) {
    final bodyPaint = Paint()..color = const Color(0xFFECEFF1);
    final accentPaint = Paint()..color = const Color(0xFF1565C0);
    final flamePaint = Paint()..color = const Color(0xFFFF6D00);
    // body
    final bodyPath = Path();
    bodyPath.moveTo(cx, cy - r * 0.9);
    bodyPath.quadraticBezierTo(
      cx + r * 0.5,
      cy - r * 0.3,
      cx + r * 0.45,
      cy + r * 0.4,
    );
    bodyPath.lineTo(cx - r * 0.45, cy + r * 0.4);
    bodyPath.quadraticBezierTo(cx - r * 0.5, cy - r * 0.3, cx, cy - r * 0.9);
    canvas.drawPath(bodyPath, bodyPaint);
    // window
    canvas.drawCircle(Offset(cx, cy - r * 0.1), r * 0.22, accentPaint);
    canvas.drawCircle(
      Offset(cx, cy - r * 0.1),
      r * 0.15,
      Paint()..color = const Color(0xFF90CAF9),
    );
    // fins
    final finPaint = Paint()..color = const Color(0xFF1976D2);
    final leftFin = Path();
    leftFin.moveTo(cx - r * 0.45, cy + r * 0.4);
    leftFin.lineTo(cx - r * 0.8, cy + r * 0.8);
    leftFin.lineTo(cx - r * 0.45, cy + r * 0.7);
    leftFin.close();
    canvas.drawPath(leftFin, finPaint);
    final rightFin = Path();
    rightFin.moveTo(cx + r * 0.45, cy + r * 0.4);
    rightFin.lineTo(cx + r * 0.8, cy + r * 0.8);
    rightFin.lineTo(cx + r * 0.45, cy + r * 0.7);
    rightFin.close();
    canvas.drawPath(rightFin, finPaint);
    // flame
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + r * 0.75),
        width: r * 0.35,
        height: r * 0.45,
      ),
      flamePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + r * 0.7),
        width: r * 0.2,
        height: r * 0.3,
      ),
      Paint()..color = const Color(0xFFFFD600),
    );
  }

  // ── Treasure Chest ──
  void _paintChest(Canvas canvas, Size size, double cx, double cy, double r) {
    final woodPaint = Paint()..color = const Color(0xFF8D6E63);
    final darkWood = Paint()..color = const Color(0xFF5D4037);
    final goldPaint = Paint()..color = const Color(0xFFFFD600);
    // base
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, cy + r * 0.35),
          width: r * 1.7,
          height: r * 0.9,
        ),
        Radius.circular(r * 0.12),
      ),
      woodPaint,
    );
    // lid
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, cy - r * 0.25),
          width: r * 1.7,
          height: r * 0.5,
        ),
        Radius.circular(r * 0.12),
      ),
      darkWood,
    );
    // gold bands
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, cy + r * 0.1),
          width: r * 1.7,
          height: r * 0.15,
        ),
        Radius.circular(r * 0.07),
      ),
      goldPaint,
    );
    // lock
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, cy + r * 0.1),
          width: r * 0.3,
          height: r * 0.35,
        ),
        Radius.circular(r * 0.08),
      ),
      goldPaint,
    );
    canvas.drawCircle(Offset(cx, cy + r * 0.05), r * 0.1, darkWood);
  }

  // ── Rainbow ──
  void _paintRainbow(Canvas canvas, Size size, double cx, double cy, double r) {
    final colors = [
      const Color(0xFFE53935),
      const Color(0xFFFF8A65),
      const Color(0xFFFFD600),
      const Color(0xFF4CAF50),
      const Color(0xFF1565C0),
      const Color(0xFF7C4DFF),
    ];
    for (int i = 0; i < colors.length; i++) {
      final arcR = r * (1.0 - i * 0.13);
      final arcPaint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.12;
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(cx, cy + r * 0.3),
          width: arcR * 2,
          height: arcR * 2,
        ),
        3.14159,
        3.14159,
        false,
        arcPaint,
      );
    }
    // clouds
    final cloudPaint = Paint()..color = const Color(0xFFF5F5F5);
    canvas.drawCircle(
      Offset(cx - r * 0.85, cy + r * 0.3),
      r * 0.22,
      cloudPaint,
    );
    canvas.drawCircle(
      Offset(cx - r * 0.65, cy + r * 0.2),
      r * 0.28,
      cloudPaint,
    );
    canvas.drawCircle(
      Offset(cx + r * 0.85, cy + r * 0.3),
      r * 0.22,
      cloudPaint,
    );
    canvas.drawCircle(
      Offset(cx + r * 0.65, cy + r * 0.2),
      r * 0.28,
      cloudPaint,
    );
  }

  // ── Castle ──
  void _paintCastle(Canvas canvas, Size size, double cx, double cy, double r) {
    final wallPaint = Paint()..color = const Color(0xFFB0BEC5);
    final darkPaint = Paint()..color = const Color(0xFF78909C);
    final flagPaint = Paint()..color = const Color(0xFFE53935);
    // main wall
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, cy + r * 0.3),
          width: r * 1.4,
          height: r * 1.0,
        ),
        Radius.circular(r * 0.08),
      ),
      wallPaint,
    );
    // towers
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx - r * 0.55, cy - r * 0.1),
          width: r * 0.45,
          height: r * 1.2,
        ),
        Radius.circular(r * 0.06),
      ),
      wallPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx + r * 0.55, cy - r * 0.1),
          width: r * 0.45,
          height: r * 1.2,
        ),
        Radius.circular(r * 0.06),
      ),
      wallPaint,
    );
    // battlements
    for (int i = -1; i <= 1; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx + i * r * 0.35, cy - r * 0.8),
            width: r * 0.2,
            height: r * 0.2,
          ),
          Radius.circular(r * 0.04),
        ),
        wallPaint,
      );
    }
    for (int side = -1; side <= 1; side += 2) {
      for (int i = -1; i <= 1; i++) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(
                cx + side * r * 0.55 + i * r * 0.15,
                cy - r * 0.75,
              ),
              width: r * 0.12,
              height: r * 0.18,
            ),
            Radius.circular(r * 0.03),
          ),
          wallPaint,
        );
      }
    }
    // gate
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, cy + r * 0.55),
          width: r * 0.4,
          height: r * 0.55,
        ),
        Radius.circular(r * 0.2),
      ),
      darkPaint,
    );
    // windows
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx - r * 0.55, cy - r * 0.2),
          width: r * 0.18,
          height: r * 0.25,
        ),
        Radius.circular(r * 0.09),
      ),
      darkPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx + r * 0.55, cy - r * 0.2),
          width: r * 0.18,
          height: r * 0.25,
        ),
        Radius.circular(r * 0.09),
      ),
      darkPaint,
    );
    // flag
    final flagPath = Path();
    flagPath.moveTo(cx, cy - r * 0.8);
    flagPath.lineTo(cx + r * 0.25, cy - r * 0.65);
    flagPath.lineTo(cx, cy - r * 0.5);
    flagPath.close();
    canvas.drawPath(flagPath, Paint()..color = flagPaint.color);
    final polePaint = Paint()
      ..color = darkPaint.color
      ..strokeWidth = r * 0.06;
    canvas.drawLine(
      Offset(cx, cy - r * 0.8),
      Offset(cx, cy - r * 0.3),
      polePaint,
    );
  }

  // ── Planet ──
  void _paintPlanet(Canvas canvas, Size size, double cx, double cy, double r) {
    final planetPaint = Paint()..color = const Color(0xFF7C4DFF);
    final ringPaint = Paint()
      ..color = const Color(0xFFFFD600)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.18;
    final highlightPaint = Paint()..color = const Color(0xFFB39DDB);
    canvas.drawCircle(Offset(cx, cy), r * 0.75, planetPaint);
    canvas.drawCircle(
      Offset(cx - r * 0.2, cy - r * 0.2),
      r * 0.25,
      highlightPaint,
    );
    // ring
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: r * 1.9, height: r * 0.55),
      ringPaint,
    );
    // redraw planet center to cover ring
    final clipPaint = Paint()..color = planetPaint.color;
    canvas.drawCircle(Offset(cx, cy), r * 0.75, clipPaint);
    canvas.drawCircle(
      Offset(cx - r * 0.2, cy - r * 0.2),
      r * 0.25,
      highlightPaint,
    );
    // ring front arc
    final frontRingPaint = Paint()
      ..color = const Color(0xFFFFD600)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.18;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, cy), width: r * 1.9, height: r * 0.55),
      0,
      3.14159,
      false,
      frontRingPaint,
    );
  }

  // ── Galaxy Globe ──
  void _paintGalaxyGlobe(
    Canvas canvas,
    Size size,
    double cx,
    double cy,
    double r,
  ) {
    // outer glass
    final glassPaint = Paint()
      ..shader =
          RadialGradient(
            center: const Alignment(-0.3, -0.3),
            colors: [const Color(0xFF90CAF9), const Color(0xFF1A237E)],
          ).createShader(
            Rect.fromCircle(center: Offset(cx, cy - r * 0.1), radius: r * 0.85),
          );
    canvas.drawCircle(Offset(cx, cy - r * 0.1), r * 0.85, glassPaint);
    // stars inside
    final starPaint = Paint()..color = Colors.white;
    final starPositions = [
      Offset(cx - r * 0.3, cy - r * 0.4),
      Offset(cx + r * 0.4, cy - r * 0.2),
      Offset(cx - r * 0.5, cy + r * 0.1),
      Offset(cx + r * 0.2, cy + r * 0.3),
      Offset(cx, cy - r * 0.6),
      Offset(cx + r * 0.5, cy + r * 0.1),
      Offset(cx - r * 0.1, cy + r * 0.5),
      Offset(cx + r * 0.3, cy - r * 0.55),
    ];
    for (final sp in starPositions) {
      canvas.drawCircle(sp, r * 0.04, starPaint);
    }
    // nebula swirl
    final nebulaPath = Path();
    nebulaPath.moveTo(cx - r * 0.4, cy);
    nebulaPath.cubicTo(
      cx - r * 0.1,
      cy - r * 0.4,
      cx + r * 0.3,
      cy - r * 0.1,
      cx + r * 0.4,
      cy + r * 0.3,
    );
    canvas.drawPath(
      nebulaPath,
      Paint()
        ..color = const Color(0x557C4DFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.15
        ..strokeCap = StrokeCap.round,
    );
    // glass highlight
    canvas.drawCircle(
      Offset(cx - r * 0.3, cy - r * 0.45),
      r * 0.2,
      Paint()..color = const Color(0x44FFFFFF),
    );
    // base
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, cy + r * 0.85),
          width: r * 0.7,
          height: r * 0.2,
        ),
        Radius.circular(r * 0.1),
      ),
      Paint()..color = const Color(0xFF37474F),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, cy + r * 0.95),
          width: r * 0.9,
          height: r * 0.1,
        ),
        Radius.circular(r * 0.05),
      ),
      Paint()..color = const Color(0xFF263238),
    );
  }

  double _cos(double x) => 1 - x * x / 2 + x * x * x * x / 24;
  double _sin(double x) => x - x * x * x / 6 + x * x * x * x * x / 120;

  @override
  bool shouldRepaint(GiftArtworkPainter oldDelegate) =>
      oldDelegate.giftId != giftId;
}
