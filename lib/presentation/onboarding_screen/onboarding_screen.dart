import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/models/journey_models.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import './widgets/object_artwork_widget.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  // TODO: Replace with Riverpod for production
  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _entranceController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _entranceController.value = 1;
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  Future<void> _onStartJourney() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    if (!mounted) return;
    context.go(AppRoutes.journeysScreen);
  }

  Future<void> _onExploreDemo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    if (!mounted) return;
    context.go(AppRoutes.exploreScreen);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Floating potato hero
              ScaleTransition(
                scale: _scaleAnimation,
                child: _buildPotatoHero(size),
              ),
              const Spacer(flex: 2),
              // Text content
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildTextContent(),
                ),
              ),
              const Spacer(flex: 3),
              // CTAs
              FadeTransition(opacity: _fadeAnimation, child: _buildCTAs()),
              SizedBox(height: bottomPadding + 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPotatoHero(Size size) {
    final dimension = (size.width * 0.78)
        .clamp(180.0, size.height * 0.32)
        .clamp(180.0, 320.0);
    return SizedBox(
      width: dimension,
      height: dimension,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(child: CustomPaint(painter: _JourneyOrbitPainter())),
          ObjectShowcase(type: ObjectType.potato, size: dimension * 0.8),
          const Positioned(
            top: 0,
            right: 2,
            child: ObjectArtworkWidget(
              type: ObjectType.paperPlane,
              size: 66,
              animate: true,
            ),
          ),
          const Positioned(
            bottom: 4,
            left: 0,
            child: ObjectArtworkWidget(
              type: ObjectType.heart,
              size: 50,
              animate: true,
            ),
          ),
          const Positioned(
            top: 30,
            left: 0,
            child: ObjectArtworkWidget(
              type: ObjectType.star,
              size: 42,
              animate: true,
            ),
          ),
          // Dotted route markers
          Positioned(
            top: 12,
            right: 90,
            child: _routeMarker(AppTheme.secondary),
          ),
          Positioned(
            bottom: 20,
            left: 90,
            child: _routeMarker(AppTheme.primary),
          ),
          Positioned(
            top: 110,
            left: 4,
            child: _routeMarker(AppTheme.potatoAccent),
          ),
        ],
      ),
    );
  }

  Widget _routeMarker(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withAlpha(153),
        border: Border.all(color: color, width: 1.5),
      ),
    );
  }

  Widget _buildTextContent() {
    return Column(
      children: [
        // App name
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Pass ',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimaryLight,
              ),
            ),
            Text(
              'It On',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 28,
                fontWeight: FontWeight.w400,
                color: AppTheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'How far can a little\npotato go?',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimaryLight,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Send something small.\nWatch its story grow.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppTheme.textSecondaryLight,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildCTAs() {
    return Column(
      children: [
        // Primary button
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _onStartJourney,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(27),
              ),
            ),
            child: const Text(
              'Start a journey',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Secondary button
        TextButton(
          onPressed: _onExploreDemo,
          child: const Text(
            'Explore the demo',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondaryLight,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Local note
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.secondaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.phone_iphone_rounded,
                size: 14,
                color: AppTheme.secondary,
              ),
              SizedBox(width: 6),
              Flexible(
                child: Text(
                  'An interactive preview. Journeys are saved on this device.',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                    color: AppTheme.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _JourneyOrbitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: size.width * 0.94,
      height: size.height * 0.68,
    );
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-0.35);
    canvas.translate(-size.width / 2, -size.height / 2);
    canvas.drawOval(
      bounds,
      Paint()
        ..color = AppTheme.potatoAccent.withAlpha(48)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
