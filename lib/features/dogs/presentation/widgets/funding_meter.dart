import 'package:flutter/material.dart';
import 'package:sponsor_a_dog/core/theme/app_colors.dart';

/// Shows how much of [goalCredits] (this dog's monthly funding goal, in
/// credits — $1 = 1 credit) is currently pledged by all Angels, via
/// [fundedCredits].
class FundingMeter extends StatelessWidget {
  const FundingMeter({required this.fundedCredits, required this.goalCredits, super.key});

  final int fundedCredits;
  final int goalCredits;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = goalCredits == 0 ? 0.0 : (fundedCredits / goalCredits).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '\$$fundedCredits of \$$goalCredits funded this month',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.zero,
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: AppColors.neutralFill,
            valueColor: const AlwaysStoppedAnimation(AppColors.mustard),
          ),
        ),
      ],
    );
  }
}
