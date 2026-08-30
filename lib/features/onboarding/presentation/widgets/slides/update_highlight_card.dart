import 'package:brutalist_ui/brutalist_ui.dart' show NeoBadge, NeoBox;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sponsor_a_dog/core/constants/app_spacing.dart';
import 'package:sponsor_a_dog/core/theme/app_colors.dart';
import 'package:sponsor_a_dog/features/dogs/domain/entities/dog_media.dart';
import 'package:sponsor_a_dog/features/dogs/domain/entities/dog_update_highlight.dart';

/// A single card in the real-update marquee: photo/video thumbnail, dog
/// name, care tag, and short caption. Used by `who_these_dogs_slide.dart`'s
/// [AutoScrollingRow], which lays cards out in a [Row] — a fixed overall
/// height keeps every card the same size regardless of whether a given
/// highlight has a care tag or caption, so the row doesn't look uneven.
class UpdateHighlightCard extends StatelessWidget {
  const UpdateHighlightCard({required this.highlight, super.key});

  static const height = 290.0;

  final DogUpdateHighlight highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final media = highlight.media;
    final thumbnailUrl =
        media.mediaType == DogMediaType.video ? (media.thumbnailUrl ?? media.url) : media.url;

    return SizedBox(
      height: height,
      child: NeoBox(
        padding: EdgeInsets.zero,
        shadowOffset: Offset.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: CachedNetworkImage(
                imageUrl: thumbnailUrl,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(
                  color: AppColors.neutralFill,
                  child: const Icon(LucideIcons.image, color: AppColors.bodyGray),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      Expanded(
                        child: Text(
                          highlight.media.caption!,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.bodyGray,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
