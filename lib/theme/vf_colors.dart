import 'package:flutter/material.dart';

/// Palette mirrors the web client at `web-platform/app/globals.css`. Keep both
/// in sync: when one shifts, port the change to the other repo too. Slugs follow
/// the same names as the CSS variables.
class VfPalette {
  const VfPalette({
    required this.background,
    required this.foreground,
    required this.card,
    required this.cardForeground,
    required this.primary,
    required this.primaryForeground,
    required this.secondary,
    required this.secondaryForeground,
    required this.muted,
    required this.mutedForeground,
    required this.accent,
    required this.accentForeground,
    required this.destructive,
    required this.success,
    required this.successForeground,
    required this.border,
    required this.input,
    required this.ring,
    required this.mistral,
    required this.zephir,
    required this.solara,
    required this.pulpe,
  });

  final Color background;
  final Color foreground;
  final Color card;
  final Color cardForeground;
  final Color primary;
  final Color primaryForeground;
  final Color secondary;
  final Color secondaryForeground;
  final Color muted;
  final Color mutedForeground;
  final Color accent;
  final Color accentForeground;
  final Color destructive;
  final Color success;
  final Color successForeground;
  final Color border;
  final Color input;
  final Color ring;

  /// Brand quartet — citrus splash v2 (Pulpe-led, juicier):
  ///   mistral → cool sky blue   (accent surfaces, charts cool tone)
  ///   zéphir  → soft cream      (secondary surfaces / sidebar wash in light;
  ///                              desaturated cool slate in dark)
  ///   solara  → golden honey    (soft brand secondary, FAB glow)
  ///   pulpe   → punchy tangerine (primary brand & CTA)
  /// Dark theme keeps the same Pulpe hue but bumps it slightly so it reads
  /// as a neon-citrus pop against the midnight-navy field.
  final Color mistral;
  final Color zephir;
  final Color solara;
  final Color pulpe;

  static const light = VfPalette(
    background: Color(0xFFFFFAF0),
    foreground: Color(0xFF2A1810),
    card: Color(0xFFFFFFFF),
    cardForeground: Color(0xFF2A1810),
    primary: Color(0xFFFF8A1F),
    primaryForeground: Color(0xFFFFFFFF),
    secondary: Color(0xFFFFE0AA),
    secondaryForeground: Color(0xFF5C3506),
    muted: Color(0xFFFFF6E6),
    mutedForeground: Color(0xFF8A6B4F),
    accent: Color(0xFF67CEEA),
    accentForeground: Color(0xFF07344B),
    destructive: Color(0xFFE64528),
    success: Color(0xFF4FA866),
    successForeground: Color(0xFFFFFFFF),
    border: Color(0xFFF2D9A8),
    input: Color(0xFFF2D9A8),
    ring: Color(0xFFFF8A1F),
    mistral: Color(0xFF67CEEA),
    zephir: Color(0xFFFFE0AA),
    solara: Color(0xFFFFC065),
    pulpe: Color(0xFFFF8A1F),
  );

  static const dark = VfPalette(
    background: Color(0xFF0C141E),
    foreground: Color(0xFFE8EEF4),
    card: Color(0xFF131C28),
    cardForeground: Color(0xFFE8EEF4),
    primary: Color(0xFFFF9A33),
    primaryForeground: Color(0xFF0C141E),
    secondary: Color(0xFF1F2A38),
    secondaryForeground: Color(0xFFE8EEF4),
    muted: Color(0xFF18222F),
    mutedForeground: Color(0xFF8FA3B8),
    accent: Color(0xFF67CEEA),
    accentForeground: Color(0xFF062236),
    destructive: Color(0xFFFF6A4A),
    success: Color(0xFF6FDC9C),
    successForeground: Color(0xFF062236),
    border: Color(0x14E8EEF4),
    input: Color(0x1FE8EEF4),
    ring: Color(0xFFFF9A33),
    mistral: Color(0xFF67CEEA),
    zephir: Color(0xFF2A2F3B),
    solara: Color(0xFFFFD089),
    pulpe: Color(0xFFFF9A33),
  );
}

/// Exposes the V-Fridge palette through the standard ThemeExtension lookup so
/// widgets can grab brand-only colors (mistral, zéphir, success, etc.) without
/// duplicating the constants. Material's ColorScheme stays the primary source
/// for primary/secondary/surface — only the extras live here.
class VfColors extends ThemeExtension<VfColors> {
  const VfColors({
    required this.mistral,
    required this.zephir,
    required this.solara,
    required this.pulpe,
    required this.success,
    required this.successForeground,
    required this.mutedForeground,
    required this.accentForeground,
  });

  final Color mistral;
  final Color zephir;
  final Color solara;
  final Color pulpe;
  final Color success;
  final Color successForeground;
  final Color mutedForeground;
  final Color accentForeground;

  static VfColors fromPalette(VfPalette p) => VfColors(
        mistral: p.mistral,
        zephir: p.zephir,
        solara: p.solara,
        pulpe: p.pulpe,
        success: p.success,
        successForeground: p.successForeground,
        mutedForeground: p.mutedForeground,
        accentForeground: p.accentForeground,
      );

  @override
  VfColors copyWith({
    Color? mistral,
    Color? zephir,
    Color? solara,
    Color? pulpe,
    Color? success,
    Color? successForeground,
    Color? mutedForeground,
    Color? accentForeground,
  }) =>
      VfColors(
        mistral: mistral ?? this.mistral,
        zephir: zephir ?? this.zephir,
        solara: solara ?? this.solara,
        pulpe: pulpe ?? this.pulpe,
        success: success ?? this.success,
        successForeground: successForeground ?? this.successForeground,
        mutedForeground: mutedForeground ?? this.mutedForeground,
        accentForeground: accentForeground ?? this.accentForeground,
      );

  @override
  VfColors lerp(ThemeExtension<VfColors>? other, double t) {
    if (other is! VfColors) return this;
    return VfColors(
      mistral: Color.lerp(mistral, other.mistral, t)!,
      zephir: Color.lerp(zephir, other.zephir, t)!,
      solara: Color.lerp(solara, other.solara, t)!,
      pulpe: Color.lerp(pulpe, other.pulpe, t)!,
      success: Color.lerp(success, other.success, t)!,
      successForeground: Color.lerp(successForeground, other.successForeground, t)!,
      mutedForeground: Color.lerp(mutedForeground, other.mutedForeground, t)!,
      accentForeground: Color.lerp(accentForeground, other.accentForeground, t)!,
    );
  }
}

extension VfColorsX on BuildContext {
  /// `context.vfColors` — pulls the brand-only extension from the active theme.
  /// Returns the light palette as a safe fallback when no theme is registered.
  VfColors get vfColors =>
      Theme.of(this).extension<VfColors>() ?? VfColors.fromPalette(VfPalette.light);
}
