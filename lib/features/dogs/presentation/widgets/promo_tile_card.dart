import 'package:brutalist_ui/brutalist_ui.dart' show NeoBox, NeoButton, NeoCard;
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sponsor_a_dog/core/constants/app_spacing.dart';
import 'package:sponsor_a_dog/core/theme/app_colors.dart';
import 'package:sponsor_a_dog/features/dogs/domain/entities/promo_tile.dart';

/// Donation-upsell card spliced into the Explore feed, e.g. "Large portions".
class PromoTileCard extends StatelessWidget {
  const PromoTileCard({required this.tile, this.onTap, super.key});

  final PromoTile tile;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: NeoCard(
        color: AppColors.mustard.withValues(alpha: 0.15),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              NeoBox(
                color: AppColors.ground,
                shadowOffset: Offset.zero,
                constraints: const BoxConstraints.tightFor(width: 88, height: 88),
                alignment: Alignment.center,
                child: const Icon(LucideIcons.heart, size: 40, color: AppColors.ink),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(tile.title, style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.xs),
              Text(
                tile.subtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.bodyGray),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: NeoButton(
                  onPressed: onTap,
                  child: Text(tile.ctaLabel.toUpperCase()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
