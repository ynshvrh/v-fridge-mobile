import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/vf_colors.dart';

/// Citrus-in-water ambient backdrop: three soft colour blobs (two warm orange,
/// one cool blue) slowly drift around the screen on top of the surface
/// background. Anything placed inside reads on top via [child]. Safe to use
/// behind scrollable content — the orbs sit on a fixed layer.
///
/// Pass [intensity] in `[0, 1]` to dial the effect down on dense screens.
class AmbientBackground extends StatefulWidget {
  const AmbientBackground({
    super.key,
    required this.child,
    this.intensity = 1,
  });

  final Widget child;
  final double intensity;

  @override
  State<AmbientBackground> createState() => _AmbientBackgroundState();
}

class _AmbientBackgroundState extends State<AmbientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _t;

  @override
  void initState() {
    super.initState();
    // Long, ambient cycle — we never want the motion to feel like a loop.
    _t = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();
  }

  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vf = context.vfColors;
    // Orbs sit on top of whatever the surrounding Scaffold already paints.
    // Inner screens that introduce their own Scaffold should set
    // `backgroundColor: Colors.transparent` so the orbs stay visible.
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _t,
              builder: (context, _) {
                return CustomPaint(
                  painter: _AmbientPainter(
                    t: _t.value,
                    pulpe: vf.pulpe,
                    solara: vf.solara,
                    mistral: vf.mistral,
                    intensity: widget.intensity.clamp(0, 1),
                  ),
                );
              },
            ),
          ),
        ),
        Positioned.fill(child: widget.child),
      ],
    );
  }
}

class _AmbientPainter extends CustomPainter {
  _AmbientPainter({
    required this.t,
    required this.pulpe,
    required this.solara,
    required this.mistral,
    required this.intensity,
  });

  final double t;       // 0..1 normalised time across the controller's period
  final Color pulpe;
  final Color solara;
  final Color mistral;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    if (intensity == 0) return;
    final w = size.width;
    final h = size.height;

    // Three lazy orbits. Each blob has its own phase + radius so they never
    // cluster predictably.
    _drawBlob(
      canvas,
      center: Offset(
        w * (0.22 + 0.08 * math.sin(2 * math.pi * t)),
        h * (0.18 + 0.06 * math.cos(2 * math.pi * t)),
      ),
      radius: w * 0.55,
      color: pulpe,
      opacity: 0.18 * intensity,
    );
    _drawBlob(
      canvas,
      center: Offset(
        w * (0.85 + 0.07 * math.cos(2 * math.pi * (t + 0.33))),
        h * (0.70 + 0.07 * math.sin(2 * math.pi * (t + 0.33))),
      ),
      radius: w * 0.5,
      color: solara,
      opacity: 0.16 * intensity,
    );
    _drawBlob(
      canvas,
      center: Offset(
        w * (0.10 + 0.10 * math.cos(2 * math.pi * (t + 0.66))),
        h * (0.85 + 0.05 * math.sin(2 * math.pi * (t + 0.66))),
      ),
      radius: w * 0.45,
      color: mistral,
      opacity: 0.18 * intensity,
    );
  }

  void _drawBlob(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required Color color,
    required double opacity,
  }) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: opacity),
          color.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _AmbientPainter old) =>
      old.t != t ||
      old.pulpe != pulpe ||
      old.solara != solara ||
      old.mistral != mistral ||
      old.intensity != intensity;
}
