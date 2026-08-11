import 'package:brutalist_ui/brutalist_ui.dart' show NeoBadge, NeoBox;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sponsor_a_dog/core/constants/app_spacing.dart';
import 'package:sponsor_a_dog/core/theme/app_colors.dart';
import 'package:sponsor_a_dog/features/dogs/domain/entities/dog.dart';

class ExploreDogCard extends StatelessWidget {
  const ExploreDogCard({required this.dog, this.onTap, super.key});

  final Dog dog;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final years = (dog.ageInMonths / 12).round();

    // How far the info card pokes out below the photo's bottom edge; the
    // rest of the card's height overlaps up into the photo.
    const protrusion = AppSpacing.md;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                NeoBox(
                  shadowOffset: Offset.zero,
                  padding: EdgeInsets.zero,
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: dog.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppColors.neutralFill,
                            child: const Center(
                              child: CupertinoActivityIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.neutralFill,
                            child: const Icon(
                              LucideIcons.image,
                              size: 48,
                              color: AppColors.bodyGray,
                            ),
                          ),
                        ),
                        if (dog.careTag != null)
                          Positioned(
                            top: AppSpacing.sm,
                            right: AppSpacing.sm,
                            child: _Badge(label: dog.careTag!),
                          ),
                      ],
                    ),
                  ),
                ),
                // Straddles the photo's bottom edge instead of sitting fully
                // inside it: most of the card overlaps up into the photo,
                // `protrusion` worth of it hangs below.
                Positioned(
                  left: AppSpacing.sm,
                  right: AppSpacing.sm,
                  bottom: -protrusion,
                  child: NeoBox(
                    color: AppColors.ground,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(dog.name, style: theme.textTheme.titleLarge),
                            if (dog.sex != null) ...[
                              const SizedBox(width: 6),
                              Text(
                                dog.sex == 'female' ? '♀' : '♂',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: dog.sex == 'female'
                                      ? const Color(0xFFE0559C)
                                      : const Color(0xFF3D7FE0),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${dog.breed} · $years ${years == 1 ? 'year' : 'years'}',
                          style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.bodyGray),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dog.story,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(color: AppColors.bodyGray),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Reserves room for the protruding part of the info card so it
            // doesn't overlap whatever comes after this card in the feed.
            const SizedBox(height: protrusion),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return NeoBadge(child: Text(label));
  }
}
