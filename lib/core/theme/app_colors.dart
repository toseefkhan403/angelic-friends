import 'package:flutter/material.dart';

/// Palette sampled from the onboarding reference illustration.
/// See docs/PRODUCT_SPEC.md §8.
abstract final class AppColors {
  static const ink = Color(0xFF000000);
  static const ground = Color(0xFFFFFFFF);
  static const mustard = Color(0xFFFEC81D);
  static const bodyGray = Color(0xFF8F8F8F);

  /// Not sampled from the reference — flat neutrals used for fills/borders
  /// (input backgrounds, card outlines, inactive dots) to stay off-white
  /// without introducing a tinted tonal palette.
  static const neutralFill = Color(0xFFF2F2F2);
  static const outline = Color(0xFFE3E3E3);
}
