import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sponsor_a_dog/core/theme/app_colors.dart';

/// Design tokens follow docs/PRODUCT_SPEC.md §8: Playpen Sans for headlines
/// and moments of warmth, Comfortaa for body copy and UI chrome.
abstract final class AppTheme {
  static final ColorScheme _colorScheme = const ColorScheme.light(
    primary: AppColors.mustard,
    onPrimary: AppColors.ink,
    secondary: AppColors.mustard,
    onSecondary: AppColors.ink,
    surface: AppColors.ground,
    onSurface: AppColors.ink,
    error: Color(0xFFB3261E),
    onError: AppColors.ground,
  ).copyWith(
    onSurfaceVariant: AppColors.bodyGray,
    surfaceContainerHighest: AppColors.neutralFill,
    outline: AppColors.outline,
    outlineVariant: AppColors.outline,
  );

  static final TextTheme _textTheme = TextTheme(
    displayLarge: GoogleFonts.playpenSans(
      fontSize: 40,
      fontWeight: FontWeight.w600,
      color: AppColors.ink,
    ),
    displayMedium: GoogleFonts.playpenSans(
      fontSize: 34,
      fontWeight: FontWeight.w600,
      color: AppColors.ink,
    ),
    displaySmall: GoogleFonts.playpenSans(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: AppColors.ink,
    ),
    headlineLarge: GoogleFonts.playpenSans(
      fontSize: 30,
      fontWeight: FontWeight.w600,
      color: AppColors.ink,
    ),
    headlineMedium: GoogleFonts.playpenSans(
      fontSize: 26,
      fontWeight: FontWeight.w600,
      color: AppColors.ink,
    ),
    headlineSmall: GoogleFonts.playpenSans(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: AppColors.ink,
    ),
    titleLarge: GoogleFonts.comfortaa(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: AppColors.ink,
    ),
    titleMedium: GoogleFonts.comfortaa(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.ink,
    ),
    titleSmall: GoogleFonts.comfortaa(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.ink,
    ),
    bodyLarge: GoogleFonts.comfortaa(fontSize: 16, color: AppColors.ink),
    bodyMedium: GoogleFonts.comfortaa(fontSize: 14, color: AppColors.ink),
    bodySmall: GoogleFonts.comfortaa(fontSize: 12, color: AppColors.bodyGray),
    labelLarge: GoogleFonts.comfortaa(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: AppColors.ink,
    ),
    labelMedium: GoogleFonts.comfortaa(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.ink,
    ),
    labelSmall: GoogleFonts.comfortaa(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: AppColors.bodyGray,
    ),
  );

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: _colorScheme,
        scaffoldBackgroundColor: AppColors.ground,
        textTheme: _textTheme,
        // Brutalist: buttons press into their own hard shadow instead of
        // rippling (package:brutalist_ui's NeoButton). Kill Material's
        // ripple/highlight globally so stock widgets that don't go through
        // Neo components (ListTile, NavigationBar) match.
        splashFactory: NoSplash.splashFactory,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          backgroundColor: AppColors.ground,
          foregroundColor: AppColors.ink,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: _textTheme.titleLarge,
        ),
        // Fallback styling for any stock FilledButton/OutlinedButton —
        // primary CTAs use NeoButton directly for the press/shadow
        // interaction, which ButtonStyle can't express.
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.mustard,
            foregroundColor: AppColors.ink,
            disabledBackgroundColor: AppColors.mustard.withValues(alpha: 0.4),
            disabledForegroundColor: AppColors.ink.withValues(alpha: 0.4),
            minimumSize: const Size(64, 56),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            shape: const RoundedRectangleBorder(
              side: BorderSide(color: AppColors.ink, width: 2),
            ),
            textStyle: _textTheme.labelLarge,
            elevation: 0,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.ink,
            side: const BorderSide(color: AppColors.ink, width: 2),
            minimumSize: const Size(64, 56),
            shape: const RoundedRectangleBorder(),
            textStyle: _textTheme.labelLarge,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.ink,
            textStyle: _textTheme.labelMedium,
            shape: const RoundedRectangleBorder(),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.neutralFill,
          hintStyle: _textTheme.bodyLarge?.copyWith(color: AppColors.bodyGray),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: AppColors.ink, width: 2),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: AppColors.ink, width: 2),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: AppColors.ink, width: 3),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        cardTheme: const CardThemeData(
          color: AppColors.ground,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(side: BorderSide(color: AppColors.ink, width: 2)),
        ),
        dividerTheme: const DividerThemeData(color: AppColors.ink, space: 1),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.ground,
          surfaceTintColor: Colors.transparent,
          indicatorColor: AppColors.mustard,
          indicatorShape: const RoundedRectangleBorder(
            side: BorderSide(color: AppColors.ink, width: 2),
          ),
          elevation: 0,
          height: 64,
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => _textTheme.labelSmall?.copyWith(
              color: AppColors.ink,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w700
                  : FontWeight.w500,
            ),
          ),
          iconTheme: WidgetStateProperty.resolveWith(
            (states) => IconThemeData(
              color: AppColors.ink,
              size: states.contains(WidgetState.selected) ? 24 : 22,
            ),
          ),
        ),
      );

  // The reference design is a flat white/black/mustard system with no dark
  // variant (§8) — mirror light so system dark mode doesn't fall back to
  // Material defaults that clash with it.
  static ThemeData get dark => light;
}
