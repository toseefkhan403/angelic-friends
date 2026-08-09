import 'package:brutalist_ui/brutalist_ui.dart' show NeoButton;
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sponsor_a_dog/core/constants/app_spacing.dart';
import 'package:sponsor_a_dog/core/theme/app_colors.dart';

/// The "My Dogs" tab. No `sponsorships` data source exists yet
/// (docs/DATABASE_SCHEMA.md), so this always renders the spec's
/// empty state (PRODUCT_SPEC.md §4.6) rather than a placeholder list.
class MyDogsPage extends StatelessWidget {
  const MyDogsPage({this.onExplore, super.key});

  final VoidCallback? onExplore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('My Dogs')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.heart, size: 48, color: AppColors.bodyGray),
              const SizedBox(height: AppSpacing.md),
              Text(
                "You haven't sponsored a dog yet",
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Meet the dogs waiting for an angel and start your first sponsorship.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.bodyGray),
              ),
              const SizedBox(height: AppSpacing.lg),
              NeoButton(onPressed: onExplore, child: const Text('Meet the dogs')),
            ],
          ),
        ),
      ),
    );
  }
}
