import 'dart:math' as math;
import 'package:flutter/material.dart';

enum ArtworkMotion { float, heartbeat, bloom, glide, shimmer, sway }

/// Locally bundled, alpha-preserving studio renders with restrained motion.
/// Only larger artwork animates; small list thumbnails remain inexpensive.
class ImmersiveArtwork extends StatefulWidget {
  final String asset;
  final double size;
  final String label;
  final bool animate;
  final ArtworkMotion motion;
  final WidgetBuilder? fallback;

  const ImmersiveArtwork({
    required this.asset,
    required this.size,
    required this.label,
    this.animate = false,
    this.motion = ArtworkMotion.float,
    this.fallback,
    super.key,
  });

  @override
  State<ImmersiveArtwork> createState() => _ImmersiveArtworkState();
}

class _ImmersiveArtworkState extends State<ImmersiveArtwork>
    with SingleTickerProviderStateMixin {
  late final AnimationController _life = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  );
  Offset _tilt = Offset.zero;
  bool _pressed = false;
  bool _reducedMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncMotion();
  }

  @override
  void didUpdateWidget(ImmersiveArtwork oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncMotion();
  }

  void _syncMotion() {
    _reducedMotion = MediaQuery.disableAnimationsOf(context);
    if (widget.animate &&
        !_reducedMotion &&
        TickerMode.valuesOf(context).enabled) {
      if (!_life.isAnimating) _life.repeat();
    } else {
      _life.stop();
    }
  }

  @override
  void dispose() {
    _life.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pixels = (widget.size * MediaQuery.devicePixelRatioOf(context))
        .ceil()
        .clamp(64, 1024);
    final image = Image.asset(
      widget.asset,
      width: widget.size,
      height: widget.size,
      fit: BoxFit.contain,
      cacheWidth: pixels,
      filterQuality: FilterQuality.medium,
      gaplessPlayback: true,
      excludeFromSemantics: true,
      errorBuilder: (context, error, stack) =>
          widget.fallback?.call(context) ?? const SizedBox.shrink(),
    );
    return Semantics(
      image: true,
      label: widget.label,
      child: RepaintBoundary(
        child: SizedBox.square(
          dimension: widget.size,
          child: MouseRegion(
            onHover: widget.animate && !_reducedMotion
                ? (event) {
                    setState(
                      () => _tilt = Offset(
                        (event.localPosition.dx / widget.size - 0.5).clamp(
                          -0.5,
                          0.5,
                        ),
                        (event.localPosition.dy / widget.size - 0.5).clamp(
                          -0.5,
                          0.5,
                        ),
                      ),
                    );
                  }
                : null,
            onExit: (_) => setState(() => _tilt = Offset.zero),
            child: Listener(
              onPointerDown: (_) => setState(() => _pressed = true),
              onPointerUp: (_) => setState(() => _pressed = false),
              onPointerCancel: (_) => setState(() => _pressed = false),
              child: AnimatedScale(
                scale: _pressed && !_reducedMotion ? 0.94 : 1,
                duration: Duration(milliseconds: _reducedMotion ? 0 : 220),
                curve: Curves.easeOutCubic,
                child: AnimatedBuilder(
                  animation: _life,
                  child: image,
                  builder: (context, child) {
                    final moving = widget.animate && !_reducedMotion;
                    final phase =
                        _life.value * math.pi * 2 +
                        (widget.asset.codeUnits.fold<int>(0, (a, b) => a + b) %
                            10);
                    final wave = moving ? math.sin(phase) : 0.0;
                    final rotation = switch (widget.motion) {
                      ArtworkMotion.glide => 0.035,
                      ArtworkMotion.sway => 0.04,
                      ArtworkMotion.bloom => 0.018,
                      _ => 0.012,
                    };
                    final breathe =
                        widget.motion == ArtworkMotion.heartbeat ||
                        widget.motion == ArtworkMotion.bloom;
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..translateByDouble(
                          widget.motion == ArtworkMotion.glide
                              ? wave * widget.size * 0.025
                              : 0,
                          wave * widget.size * 0.025,
                          0,
                          1,
                        )
                        ..scaleByDouble(
                          1 + (breathe ? wave * 0.018 : 0),
                          1 + (breathe ? wave * 0.018 : 0),
                          1,
                          1,
                        )
                        ..rotateX(-_tilt.dy * 0.12)
                        ..rotateY(_tilt.dx * 0.16)
                        ..rotateZ(wave * rotation),
                      child: child,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A luminous display space, with an elliptical floor and soft ground shadow.
class ArtworkStage extends StatelessWidget {
  final Widget child;
  final Color accent;
  final double size;
  const ArtworkStage({
    required this.child,
    required this.accent,
    required this.size,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accent.withAlpha(dark ? 58 : 32),
                    accent.withAlpha(0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: size * 0.075,
            child: Container(
              width: size * 0.72,
              height: size * 0.16,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withAlpha(dark ? 20 : 230),
                    accent.withAlpha(dark ? 38 : 40),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withAlpha(dark ? 18 : 170),
                ),
                boxShadow: [
                  BoxShadow(
                    color: accent.withAlpha(28),
                    blurRadius: size * 0.12,
                    offset: Offset(0, size * 0.04),
                  ),
                ],
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
