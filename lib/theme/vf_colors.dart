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
    required this.celadon,
    required this.celadonSoft,
    required this.violetBrand,
    required this.violetSoft,
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
  final Color celadon;
  final Color celadonSoft;
  final Color violetBrand;
  final Color violetSoft;

  static const light = VfPalette(
    background: Color(0xFFFBFCF7),
    foreground: Color(0xFF2A1E2A),
    card: Color(0xFFFFFFFF),
    cardForeground: Color(0xFF2A1E2A),
    primary: Color(0xFF8C5383),
    primaryForeground: Color(0xFFFFFFFF),
    secondary: Color(0xFFD7E7C3),
    secondaryForeground: Color(0xFF2A4A1F),
    muted: Color(0xFFF3F6EC),
    mutedForeground: Color(0xFF6B5C6B),
    accent: Color(0xFFECF3DF),
    accentForeground: Color(0xFF4C2D4A),
    destructive: Color(0xFFC0392B),
    success: Color(0xFF4A8B3A),
    successForeground: Color(0xFFFFFFFF),
    border: Color(0xFFE5E5D8),
    input: Color(0xFFE5E5D8),
    ring: Color(0xFF8C5383),
    celadon: Color(0xFFD7E7C3),
    celadonSoft: Color(0xFFECF3DF),
    violetBrand: Color(0xFF8C5383),
    violetSoft: Color(0xFFB884B0),
  );

  static const dark = VfPalette(
    background: Color(0xFF1A121A),
    foreground: Color(0xFFECF3DF),
    card: Color(0xFF241A24),
    cardForeground: Color(0xFFECF3DF),
    primary: Color(0xFFB884B0),
    primaryForeground: Color(0xFF1A121A),
    secondary: Color(0xFF3D4A33),
    secondaryForeground: Color(0xFFECF3DF),
    muted: Color(0xFF2E232E),
    mutedForeground: Color(0xFFB5A9B5),
    accent: Color(0xFF3D2F3B),
    accentForeground: Color(0xFFECF3DF),
    destructive: Color(0xFFE55B4B),
    success: Color(0xFF7CB36A),
    successForeground: Color(0xFF1A121A),
    border: Color(0x1AECF3DF),
    input: Color(0x26ECF3DF),
    ring: Color(0xFFB884B0),
    celadon: Color(0xFFB5C9A1),
    celadonSoft: Color(0xFF3D4A33),
    violetBrand: Color(0xFFB884B0),
    violetSoft: Color(0xFF6B3F65),
  );
}

/// Exposes the V-Fridge palette through the standard ThemeExtension lookup so
/// widgets can grab brand-only colors (celadon, success, etc.) without
/// duplicating the constants. Material's ColorScheme stays the primary source
/// for primary/secondary/surface — only the extras live here.
class VfColors extends ThemeExtension<VfColors> {
  const VfColors({
    required this.celadon,
    required this.celadonSoft,
    required this.violetBrand,
    required this.violetSoft,
    required this.success,
    required this.successForeground,
    required this.mutedForeground,
    required this.accentForeground,
  });

  final Color celadon;
  final Color celadonSoft;
  final Color violetBrand;
  final Color violetSoft;
  final Color success;
  final Color successForeground;
  final Color mutedForeground;
  final Color accentForeground;

  static VfColors fromPalette(VfPalette p) => VfColors(
        celadon: p.celadon,
        celadonSoft: p.celadonSoft,
        violetBrand: p.violetBrand,
        violetSoft: p.violetSoft,
        success: p.success,
        successForeground: p.successForeground,
        mutedForeground: p.mutedForeground,
        accentForeground: p.accentForeground,
      );

  @override
  VfColors copyWith({
    Color? celadon,
    Color? celadonSoft,
    Color? violetBrand,
    Color? violetSoft,
    Color? success,
    Color? successForeground,
    Color? mutedForeground,
    Color? accentForeground,
  }) =>
      VfColors(
        celadon: celadon ?? this.celadon,
        celadonSoft: celadonSoft ?? this.celadonSoft,
        violetBrand: violetBrand ?? this.violetBrand,
        violetSoft: violetSoft ?? this.violetSoft,
        success: success ?? this.success,
        successForeground: successForeground ?? this.successForeground,
        mutedForeground: mutedForeground ?? this.mutedForeground,
        accentForeground: accentForeground ?? this.accentForeground,
      );

  @override
  VfColors lerp(ThemeExtension<VfColors>? other, double t) {
    if (other is! VfColors) return this;
    return VfColors(
      celadon: Color.lerp(celadon, other.celadon, t)!,
      celadonSoft: Color.lerp(celadonSoft, other.celadonSoft, t)!,
      violetBrand: Color.lerp(violetBrand, other.violetBrand, t)!,
      violetSoft: Color.lerp(violetSoft, other.violetSoft, t)!,
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
