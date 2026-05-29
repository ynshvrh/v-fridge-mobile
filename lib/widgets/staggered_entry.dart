import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// A list-friendly entry animation: each item fades in and rises a few pixels
/// with a staggered start so the list cascades on first appear (or after a
/// scroll-in jolt). Use as a `ListView.builder` child wrapper.
///
/// `index` controls when this item enters relative to its siblings.
class StaggeredEntry extends StatelessWidget {
  const StaggeredEntry({
    super.key,
    required this.index,
    required this.child,
    this.step = const Duration(milliseconds: 55),
    this.duration = const Duration(milliseconds: 380),
    this.offset = 12,
    this.maxIndex = 12,
  });

  /// Position in the visible list. Clamped at [maxIndex] so a 200-item list
  /// doesn't take five seconds to settle.
  final int index;
  final Widget child;

  /// Delay between consecutive items.
  final Duration step;

  /// Duration of each item's fade+rise.
  final Duration duration;

  /// Pixels the item lifts from before settling.
  final double offset;

  /// Cap on the stagger so deep items don't pile up delay.
  final int maxIndex;

  @override
  Widget build(BuildContext context) {
    final effective = index.clamp(0, maxIndex);
    return child.animate(delay: step * effective).fade(
          begin: 0,
          end: 1,
          duration: duration,
          curve: Curves.easeOut,
        ).slideY(
          begin: offset / 100,
          end: 0,
          duration: duration,
          curve: Curves.easeOutCubic,
        );
  }
}
