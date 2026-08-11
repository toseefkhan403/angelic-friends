import 'package:brutalist_ui/brutalist_ui.dart' show NeoBox;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sponsor_a_dog/core/constants/app_spacing.dart';
import 'package:sponsor_a_dog/core/theme/app_colors.dart';
import 'package:sponsor_a_dog/core/widgets/auto_play_video.dart';
import 'package:sponsor_a_dog/features/dogs/domain/entities/dog_media.dart';
import 'package:sponsor_a_dog/features/dogs/domain/entities/dog_update_highlight.dart';
import 'package:sponsor_a_dog/features/onboarding/domain/entities/onboarding_slide.dart';
import 'package:sponsor_a_dog/features/onboarding/presentation/widgets/slides/slide_eyebrow.dart';

/// "From kennel to your inbox" slide: eyebrow/title/subtitle, 4 numbered
/// steps, and a card previewing a real handler update (video when one of
/// the featured highlights has one, otherwise a photo).
class LetterSlide extends StatelessWidget {
  const LetterSlide({
    required this.slide,
    required this.highlights,
    required this.isActive,
    super.key,
  });

  final OnboardingSlide slide;
  final List<DogUpdateHighlight> highlights;
  final bool isActive;

  static const _steps = [
    'Browse the dogs in need',
    'Pick one',
    'Sponsor monthly',
    'Watch their recovery, one video at a time',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final letterHighlight = highlights.isEmpty
        ? null
        : highlights.firstWhere(
            (h) => h.media.mediaType == DogMediaType.video,
            orElse: () => highlights.first,
          );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (slide.eyebrow != null) SlideEyebrow(text: slide.eyebrow!),
          const SizedBox(height: AppSpacing.sm),
          Text(slide.title, style: theme.textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            slide.subtitle,
            style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.md),
          for (var i = 0; i < _steps.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Text('${i + 1}. ${_steps[i]}', style: theme.textTheme.bodyMedium),
            ),
          const SizedBox(height: AppSpacing.lg),
          if (letterHighlight != null)
            NeoBox(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Text(
                      'Letter from ${letterHighlight.dogName}',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  AspectRatio(
                    aspectRatio: 16 / 10,
                    child: letterHighlight.media.mediaType == DogMediaType.video
                        ? AutoPlayVideo(
                            videoUrl: letterHighlight.media.url,
                            thumbnailUrl: letterHighlight.media.thumbnailUrl,
                            isActive: isActive,
                          )
                        : CachedNetworkImage(
                            imageUrl: letterHighlight.media.url,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.neutralFill,
                              child: const Icon(LucideIcons.image, color: AppColors.bodyGray),
                            ),
                          ),
                  ),
                  if (letterHighlight.media.caption != null)
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Text(
                        letterHighlight.media.caption!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.bodyGray,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
