import 'package:brutalist_ui/brutalist_ui.dart' show NeoBadge, NeoBox, NeoTextField;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sponsor_a_dog/core/constants/app_spacing.dart';
import 'package:sponsor_a_dog/core/theme/app_colors.dart';
import 'package:sponsor_a_dog/core/widgets/auto_scrolling_row.dart';
import 'package:sponsor_a_dog/features/dogs/domain/entities/dog_media.dart';
import 'package:sponsor_a_dog/features/dogs/domain/entities/dog_update_highlight.dart';
import 'package:sponsor_a_dog/features/onboarding/domain/entities/onboarding_slide.dart';
import 'package:sponsor_a_dog/features/onboarding/presentation/widgets/slides/slide_eyebrow.dart';

/// Final onboarding slide: eyebrow/title, a marquee of real update cards
/// (photo/video thumbnail + name + care tag + short caption), then the
/// name field that doubles as this app's login step.
class MarqueeNameCaptureSlide extends StatelessWidget {
  const MarqueeNameCaptureSlide({
    required this.slide,
    required this.highlights,
    required this.nameController,
    required this.onNameChanged,
    super.key,
  });

  final OnboardingSlide slide;
  final List<DogUpdateHighlight> highlights;
  final TextEditingController nameController;
  final ValueChanged<String> onNameChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (slide.eyebrow != null) SlideEyebrow(text: slide.eyebrow!),
          const SizedBox(height: AppSpacing.sm),
          Text(slide.title, style: theme.textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.lg),
          if (highlights.isNotEmpty)
            SizedBox(
              height: 220,
              child: AutoScrollingRow(
                itemCount: highlights.length,
                itemWidth: 160,
                pixelsPerSecond: 24,
                itemBuilder: (context, index) => _UpdateCard(highlight: highlights[index]),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          Text(slide.subtitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          NeoTextField(
            controller: nameController,
            textCapitalization: TextCapitalization.words,
            placeholder: 'Your name',
            onChanged: onNameChanged,
          ),
        ],
      ),
    );
  }
}

class _UpdateCard extends StatelessWidget {
  const _UpdateCard({required this.highlight});

  final DogUpdateHighlight highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final media = highlight.media;
    final thumbnailUrl =
        media.mediaType == DogMediaType.video ? (media.thumbnailUrl ?? media.url) : media.url;

    return NeoBox(
      padding: EdgeInsets.zero,
      shadowOffset: Offset.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: CachedNetworkImage(
              imageUrl: thumbnailUrl,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Container(
                color: AppColors.neutralFill,
                child: const Icon(LucideIcons.image, color: AppColors.bodyGray),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        highlight.dogName,
                        style: theme.textTheme.titleSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (highlight.careTag != null) ...[
                      const SizedBox(width: AppSpacing.xs),
                      NeoBadge(child: Text(highlight.careTag!)),
                    ],
                  ],
                ),
                if (highlight.media.caption != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    highlight.media.caption!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.bodyGray,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
