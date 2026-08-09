import 'package:brutalist_ui/brutalist_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sponsor_a_dog/core/theme/app_colors.dart';

/// Theme for package:brutalist_ui components (NeoButton, NeoTextField, ...),
/// matching [AppTheme]'s ink/mustard/ground palette and Playpen Sans/Comfortaa
/// pairing so Neo widgets sit flush with the rest of the app.
abstract final class AppNeoTheme {
  static const _fallback = NeoTypography.fallback();

  static final NeoTypography _typography = NeoTypography(
    display: GoogleFonts.playpenSans(textStyle: _fallback.display),
    headline: GoogleFonts.playpenSans(textStyle: _fallback.headline),
    title: GoogleFonts.playpenSans(textStyle: _fallback.title),
    body: GoogleFonts.comfortaa(textStyle: _fallback.body),
    label: GoogleFonts.comfortaa(textStyle: _fallback.label),
    button: GoogleFonts.comfortaa(textStyle: _fallback.button),
    caption: GoogleFonts.comfortaa(textStyle: _fallback.caption),
  );

  static final NeoColorScheme _colors = const NeoColorScheme.light().copyWith(
    background: AppColors.ground,
    surface: AppColors.ground,
    foreground: AppColors.ink,
    mutedForeground: AppColors.bodyGray,
    border: AppColors.ink,
    shadow: AppColors.ink,
    primary: AppColors.mustard,
    foregroundOnFill: AppColors.ink,
    disabled: AppColors.neutralFill,
    disabledForeground: AppColors.bodyGray,
  );

  static final NeoThemeData data = NeoThemeData(
    colors: _colors,
    typography: _typography,
    borderWidth: 2,
    borderRadius: BorderRadius.zero,
    shadowOffset: const Offset(4, 4),
  );
}
