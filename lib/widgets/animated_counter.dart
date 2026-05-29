import 'package:flutter/material.dart';

/// Tweens an integer from its previous value to [value] over [duration].
/// Pair with stat-style displays ("12 products", "3 expiring") so refreshes
/// feel like a roll-up instead of a jump.
class AnimatedCounter extends StatelessWidget {
  const AnimatedCounter({
    super.key,
    required this.value,
    this.duration = const Duration(milliseconds: 700),
    this.curve = Curves.easeOutCubic,
    this.style,
  });

  final int value;
  final Duration duration;
  final Curve curve;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: curve,
      builder: (context, v, _) {
        return Text(v.round().toString(), style: style);
      },
    );
  }
}
