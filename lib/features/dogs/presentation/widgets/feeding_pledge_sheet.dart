import 'package:brutalist_ui/brutalist_ui.dart' show NeoBox, NeoButton;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sponsor_a_dog/core/constants/app_spacing.dart';
import 'package:sponsor_a_dog/core/theme/app_colors.dart';
import 'package:sponsor_a_dog/features/angel/domain/repositories/angel_repository.dart';

/// Bottom sheet for permanently locking part of the user's available Angel
/// credit balance onto the general feeding fund (not tied to any one dog) —
/// the feeding-strays promo tile's counterpart to `donate_credits_sheet.dart`.
///
/// Returns `true` on a successful pledge, `false` if the sheet was
/// cancelled/dismissed without one.
Future<bool> showFeedingPledgeSheet(
  BuildContext context, {
  required int availableCredits,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _FeedingPledgeSheet(availableCredits: availableCredits),
  );
  return result ?? false;
}

class _FeedingPledgeSheet extends StatefulWidget {
  const _FeedingPledgeSheet({required this.availableCredits});

  final int availableCredits;

  @override
  State<_FeedingPledgeSheet> createState() => _FeedingPledgeSheetState();
}

class _FeedingPledgeSheetState extends State<_FeedingPledgeSheet> {
  double _credits = 1;
  bool _isSubmitting = false;

  Future<void> _confirm() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    final angelRepository = context.read<AngelRepository>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final result = await angelRepository.pledgeCreditsToFeeding(credits: _credits.round());

    if (!mounted) return;

    result.fold(
      (failure) => messenger.showSnackBar(SnackBar(content: Text(failure.message))),
      (_) {
        messenger.showSnackBar(
          const SnackBar(content: Text("You're now feeding the strays every month!")),
        );
        navigator.pop(true);
      },
    );

    if (mounted) setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final credits = _credits.round();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: NeoBox(
          color: AppColors.ground,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Feed the Strays', style: theme.textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.sm),
              Text('\$$credits/mo', style: theme.textTheme.displaySmall),
              if (widget.availableCredits > 1)
                Slider(
                  value: _credits,
                  min: 1,
                  max: widget.availableCredits.toDouble(),
                  divisions: widget.availableCredits - 1,
                  label: '\$$credits',
                  onChanged: (value) => setState(() => _credits = value),
                )
              else
                const SizedBox(height: AppSpacing.sm),
              Text(
                'Goes straight toward daily feedings for the strays outside our shelters.',
                style: theme.textTheme.bodySmall?.copyWith(color: AppColors.bodyGray),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                "Pledged credits are permanent and can't be moved to a dog later.",
                style: theme.textTheme.bodySmall?.copyWith(color: AppColors.bodyGray),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: NeoButton(
                  onPressed: _isSubmitting ? null : _confirm,
                  child: Text('Pledge \$$credits/mo to Feeding'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
