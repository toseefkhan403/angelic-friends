import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sponsor_a_dog/core/constants/app_spacing.dart';
import 'package:sponsor_a_dog/core/theme/app_colors.dart';
import 'package:sponsor_a_dog/features/onboarding/domain/entities/onboarding_slide.dart';

/// The opening onboarding slide: brand mark, hero illustration (50% of
/// screen height), title, subtitle.
class HeroSlide extends StatelessWidget {
  const HeroSlide({required this.slide, super.key});

  final OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageHeight = MediaQuery.of(context).size.height * 0.5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: _BrandMark(),
        ),
        SizedBox(
          height: imageHeight,
          width: double.infinity,
          child: CachedNetworkImage(
            imageUrl: slide.imageUrl ?? '',
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: AppColors.neutralFill,
              child: const Center(child: CupertinoActivityIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              color: AppColors.neutralFill,
              child: const Icon(
                LucideIcons.image,
                size: 96,
                color: AppColors.bodyGray,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(slide.title, style: theme.textTheme.headlineMedium),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    slide.subtitle,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Angelic Friends',
        style: GoogleFonts.playpenSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
      ),
    );
  }
}
