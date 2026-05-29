import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'vf_colors.dart';
import 'vf_radius.dart';

/// Builds a Material 3 [ThemeData] aligned with the web client's citrus palette
/// and radius scale. See `web-platform/app/globals.css` for the source of truth
/// and keep both in sync.
ThemeData vfLightTheme() => _buildTheme(VfPalette.light, Brightness.light);

ThemeData vfDarkTheme() => _buildTheme(VfPalette.dark, Brightness.dark);

ThemeData _buildTheme(VfPalette p, Brightness brightness) {
  final scheme = ColorScheme(
    brightness: brightness,
    primary: p.primary,
    onPrimary: p.primaryForeground,
    secondary: p.secondary,
    onSecondary: p.secondaryForeground,
    tertiary: p.solara,
    onTertiary: p.primaryForeground,
    error: p.destructive,
    onError: Colors.white,
    surface: p.card,
    onSurface: p.cardForeground,
    surfaceContainerLowest: p.background,
    surfaceContainerLow: p.muted,
    surfaceContainer: p.muted,
    // Raised internal surfaces stay neutral — using `accent` (Mistral blue)
    // here paints menus/tooltips bright cyan in both themes, which fights
    // the brand. The Mistral pop is reserved for explicit accent moments.
    surfaceContainerHigh: p.card,
    surfaceContainerHighest: p.zephir,
    outline: p.border,
    outlineVariant: p.muted,
    inverseSurface: brightness == Brightness.light ? p.foreground : p.card,
    onInverseSurface: brightness == Brightness.light ? p.background : p.foreground,
    inversePrimary: p.solara,
    shadow: Colors.black.withValues(alpha: 0.08),
    scrim: Colors.black.withValues(alpha: 0.32),
  );

  final base = ThemeData(useMaterial3: true, colorScheme: scheme, brightness: brightness);

  // Inter as a close stand-in for Geist (the web font); google_fonts streams it
  // on first launch and caches afterwards. Falls back to platform defaults if
  // the network is unreachable.
  final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
    bodyColor: p.foreground,
    displayColor: p.foreground,
  );

  return base.copyWith(
    scaffoldBackgroundColor: p.background,
    canvasColor: p.background,
    dividerColor: p.border,
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    extensions: <ThemeExtension<dynamic>>[VfColors.fromPalette(p)],

    appBarTheme: AppBarTheme(
      backgroundColor: p.background,
      foregroundColor: p.foreground,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    ),

    cardTheme: CardThemeData(
      color: p.card,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: VfRadius.brXxl,
        side: BorderSide(color: p.border),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.card,
      hintStyle: TextStyle(color: p.mutedForeground),
      labelStyle: TextStyle(color: p.mutedForeground, fontWeight: FontWeight.w600),
      border: OutlineInputBorder(
        borderRadius: VfRadius.brLg,
        borderSide: BorderSide(color: p.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: VfRadius.brLg,
        borderSide: BorderSide(color: p.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: VfRadius.brLg,
        borderSide: BorderSide(color: p.ring, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: VfRadius.brLg,
        borderSide: BorderSide(color: p.destructive),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: VfRadius.brLg,
        borderSide: BorderSide(color: p.destructive, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        shape: const RoundedRectangleBorder(borderRadius: VfRadius.brLg),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: VfRadius.brLg),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        shape: const RoundedRectangleBorder(borderRadius: VfRadius.brLg),
        side: BorderSide(color: p.border),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: const RoundedRectangleBorder(borderRadius: VfRadius.brLg),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: p.zephir,
      labelStyle: TextStyle(color: p.secondaryForeground, fontWeight: FontWeight.w600),
      side: BorderSide(color: p.border),
      shape: const RoundedRectangleBorder(borderRadius: VfRadius.brSm),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: brightness == Brightness.light ? p.foreground : p.card,
      contentTextStyle: TextStyle(
        color: brightness == Brightness.light ? p.background : p.foreground,
        fontWeight: FontWeight.w500,
      ),
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(borderRadius: VfRadius.brMd),
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: p.card,
      surfaceTintColor: Colors.transparent,
      indicatorColor: p.mistral,
      indicatorShape: const RoundedRectangleBorder(borderRadius: VfRadius.brLg),
      // Selected label/icon sit on the Mistral indicator pill, so use the
      // accent-foreground (deep navy) for high contrast in both themes.
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          color: states.contains(WidgetState.selected) ? p.accentForeground : p.mutedForeground,
          fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
          fontSize: 12,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected) ? p.accentForeground : p.mutedForeground,
        ),
      ),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: p.primary,
      foregroundColor: p.primaryForeground,
      elevation: 0,
      highlightElevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: VfRadius.brXl),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: p.card,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: VfRadius.brXl),
      titleTextStyle: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    ),

    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: p.card,
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: p.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(VfRadius.xxl)),
      ),
    ),

    dividerTheme: DividerThemeData(color: p.border, space: 1, thickness: 1),

    // Soft fade-through-slide for navigation pushes on both platforms — the
    // default Material/Cupertino transitions feel mechanical against the rest
    // of the ambient motion.
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: _VfPageTransitionsBuilder(),
        TargetPlatform.iOS:     _VfPageTransitionsBuilder(),
        TargetPlatform.linux:   _VfPageTransitionsBuilder(),
        TargetPlatform.macOS:   _VfPageTransitionsBuilder(),
        TargetPlatform.windows: _VfPageTransitionsBuilder(),
      },
    ),
  );
}

/// Light slide + fade for page pushes. Curved with `easeOutCubic` so motion
/// settles instead of snapping.
class _VfPageTransitionsBuilder extends PageTransitionsBuilder {
  const _VfPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}
