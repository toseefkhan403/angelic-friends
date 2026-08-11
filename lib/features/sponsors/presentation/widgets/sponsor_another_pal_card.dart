import 'package:brutalist_ui/brutalist_ui.dart' show NeoBox;
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sponsor_a_dog/core/constants/app_spacing.dart';
import 'package:sponsor_a_dog/core/theme/app_colors.dart';

/// Persistent CTA at the end of the "My Pups" list, encouraging another
/// sponsorship regardless of how many the user already has.
class SponsorAnotherPalCard extends StatelessWidget {
  const SponsorAnotherPalCard({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: GestureDetector(
        onTap: onTap,
        child: NeoBox(
          color: AppColors.neutralFill,
          shadowOffset: Offset.zero,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.ground,
                  border: Border.fromBorderSide(BorderSide(color: AppColors.ink, width: 2)),
                ),
                child: const Icon(LucideIcons.plus, size: 28, color: AppColors.ink),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Sponsor Another Pal', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'There are many more dogs looking for a friend like you.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(color: AppColors.bodyGray),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
