import 'package:brutalist_ui/brutalist_ui.dart' show NeoBadge, NeoBox;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sponsor_a_dog/core/constants/app_spacing.dart';
import 'package:sponsor_a_dog/core/theme/app_colors.dart';
import 'package:sponsor_a_dog/features/dogs/domain/entities/dog_media.dart';
import 'package:sponsor_a_dog/features/dogs/domain/entities/dog_update_highlight.dart';

/// A single card in the real-update marquee: photo/video thumbnail, dog
/// name, care tag, and short caption. Shared by any onboarding slide that
/// shows this marquee (see `who_these_dogs_slide.dart` and
/// `marquee_name_capture_slide.dart`).
class UpdateHighlightCard extends StatelessWidget {
  const UpdateHighlightCard({required this.highlight, super.key});

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
                if (highlight.careTag != null) ...[
                  NeoBadge(child: Text(highlight.careTag!)),
                  const SizedBox(height: 4),
                ],
                Text(
                  highlight.dogName,
                  style: theme.textTheme.titleSmall,
                  overflow: TextOverflow.ellipsis,
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
