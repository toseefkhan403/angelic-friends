import 'package:brutalist_ui/brutalist_ui.dart' show NeoBox;
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sponsor_a_dog/core/constants/app_spacing.dart';
import 'package:sponsor_a_dog/core/theme/app_colors.dart';

/// Countdown to the app's weekly update cadence (every Sunday). There's no
/// real per-dog schedule backing this yet (see docs/PRODUCT_SPEC.md §4.7,
/// deferred) — it's a fixed weekly anchor, purely informational chrome.
class NextUpdateBanner extends StatelessWidget {
  const NextUpdateBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remaining = _timeUntilNextUpdate();
    final days = remaining.inDays;
    final hours = remaining.inHours % 24;

    return NeoBox(
      color: AppColors.mustard,
      shadowOffset: Offset.zero,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.ground,
              border: Border.fromBorderSide(BorderSide(color: AppColors.ink, width: 2)),
            ),
            child: const Icon(LucideIcons.playCircle, size: 20, color: AppColors.ink),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('NEXT WEEKLY VIDEO UPDATE', style: theme.textTheme.labelSmall),
                Text('$days Days, $hours Hrs', style: theme.textTheme.titleMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Duration _timeUntilNextUpdate() {
    final now = DateTime.now();
    var next = DateTime(now.year, now.month, now.day, 9);
    while (next.weekday != DateTime.sunday || !next.isAfter(now)) {
      next = next.add(const Duration(days: 1));
    }
    return next.difference(now);
  }
}
