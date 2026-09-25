import 'package:flutter/material.dart';

import '../../../core/models/gift_models.dart';

class GiftArtworkWidget extends StatelessWidget {
  final GiftCatalogItem item;
  final double size;
  final bool showShadow;

  const GiftArtworkWidget({
    required this.item,
    this.size = 56,
    this.showShadow = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${item.name} gift illustration',
      child: Container(
        width: size,
        height: size,
        decoration: showShadow
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(size * 0.25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              )
            : null,
        child: CustomPaint(
          size: Size(size, size),
          painter: GiftArtworkPainter(
            giftId: item.id,
            primaryColor: _primaryColor,
            accentColor: _accentColor,
          ),
        ),
      ),
    );
  }

  Color get _primaryColor {
    switch (item.id) {
      case 'gift-01':
        return const Color(0xFFE87070);
      case 'gift-02':
        return const Color(0xFF4CAF50);
      case 'gift-03':
        return const Color(0xFFE53935);
      case 'gift-04':
        return const Color(0xFFFFB74D);
      case 'gift-05':
        return const Color(0xFF7C4DFF);
      case 'gift-06':
        return const Color(0xFFFF8A65);
      case 'gift-07':
        return const Color(0xFFFFD600);
      case 'gift-08':
        return const Color(0xFF4CAF50);
      case 'gift-09':
        return const Color(0xFFD4A853);
      case 'gift-10':
        return const Color(0xFF1565C0);
      case 'gift-11':
        return const Color(0xFFFFCC80);
      case 'gift-12':
        return const Color(0xFFE53935);
      case 'gift-13':
        return const Color(0xFFFFD600);
      case 'gift-14':
        return const Color(0xFFE53935);
      case 'gift-15':
        return const Color(0xFFECEFF1);
      case 'gift-16':
        return const Color(0xFF8D6E63);
      case 'gift-17':
        return const Color(0xFFE53935);
      case 'gift-18':
        return const Color(0xFFB0BEC5);
      case 'gift-19':
        return const Color(0xFF7C4DFF);
      case 'gift-20':
        return const Color(0xFF1A237E);
      default:
        return const Color(0xFFE87070);
    }
  }

  Color get _accentColor {
    switch (item.id) {
      case 'gift-01':
        return const Color(0xFFFFB3B3);
      case 'gift-02':
        return const Color(0xFF81C784);
      case 'gift-03':
        return const Color(0xFFEF9A9A);
      case 'gift-04':
        return const Color(0xFFFF8F00);
      case 'gift-05':
        return const Color(0xFFB39DDB);
      case 'gift-06':
        return const Color(0xFFF8BBD9);
      case 'gift-07':
        return const Color(0xFFFFF176);
      case 'gift-08':
        return const Color(0xFF81C784);
      case 'gift-09':
        return const Color(0xFFE8C97A);
      case 'gift-10':
        return const Color(0xFFFFD600);
      case 'gift-11':
        return const Color(0xFFF8BBD9);
      case 'gift-12':
        return const Color(0xFFFFD600);
      case 'gift-13':
        return const Color(0xFFFFF176);
      case 'gift-14':
        return const Color(0xFFFFD600);
      case 'gift-15':
        return const Color(0xFF1565C0);
      case 'gift-16':
        return const Color(0xFFFFD600);
      case 'gift-17':
        return const Color(0xFFFFD600);
      case 'gift-18':
        return const Color(0xFF78909C);
      case 'gift-19':
        return const Color(0xFFB39DDB);
      case 'gift-20':
        return const Color(0xFF90CAF9);
      default:
        return const Color(0xFFFFB3B3);
    }
  }
}
