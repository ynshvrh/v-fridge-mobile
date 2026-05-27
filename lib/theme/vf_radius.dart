import 'package:flutter/widgets.dart';

/// Border-radius scale mirroring the web client (`--radius: 0.75rem` = 12px base).
/// Use these constants instead of inline `BorderRadius.circular(12)` so the
/// look stays consistent if we ever bump the base.
class VfRadius {
  static const double xs = 8;
  static const double sm = 10;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 28;

  static const BorderRadius brXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius brSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius brMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius brLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius brXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius brXxl = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius brXxxl = BorderRadius.all(Radius.circular(xxxl));
}
