import 'package:brutalist_ui/brutalist_ui.dart' show NeoBox, NeoButton;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sponsor_a_dog/core/constants/app_spacing.dart';
import 'package:sponsor_a_dog/core/theme/app_colors.dart';
import 'package:sponsor_a_dog/features/angel/domain/repositories/angel_repository.dart';
import 'package:sponsor_a_dog/features/dogs/domain/entities/dog.dart';
import 'package:sponsor_a_dog/features/sponsors/domain/entities/sponsorship.dart';
import 'package:sponsor_a_dog/features/sponsors/domain/repositories/sponsorship_repository.dart';

/// Bottom sheet for permanently locking part of the user's available Angel
/// credit balance onto [dog]. Only ever shown once the caller has confirmed
/// `availableCredits > 0` — see `dog_detail_page.dart`.
///
/// Returns the resulting [Sponsorship] on a successful pledge (so the caller
/// can show a celebration dialog with a shortcut into that chat), or `null`
/// if the sheet was cancelled/dismissed without a successful pledge.
Future<Sponsorship?> showDonateCreditsSheet(
  BuildContext context, {
  required Dog dog,
  required int availableCredits,
}) {
  return showModalBottomSheet<Sponsorship?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _DonateCreditsSheet(dog: dog, availableCredits: availableCredits),
  );
}

class _DonateCreditsSheet extends StatefulWidget {
  const _DonateCreditsSheet({required this.dog, required this.availableCredits});

  final Dog dog;
  final int availableCredits;

  @override
  State<_DonateCreditsSheet> createState() => _DonateCreditsSheetState();
}

class _DonateCreditsSheetState extends State<_DonateCreditsSheet> {
  double _credits = 1;
  bool _isSubmitting = false;

  Future<void> _confirm() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    final angelRepository = context.read<AngelRepository>();
    final sponsorshipRepository = context.read<SponsorshipRepository>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final result = await angelRepository.pledgeCredits(
      dogId: widget.dog.id,
      credits: _credits.round(),
    );

    if (!mounted) return;

    await result.fold(
      (failure) async => messenger.showSnackBar(SnackBar(content: Text(failure.message))),
      (_) async {
        // The pledge just committed in the same database, so the resulting
        // row is already there — no polling needed, unlike the RevenueCat
        // webhook path.
        final sponsorshipsResult = await sponsorshipRepository.getMySponsorships();
        final sponsorship = sponsorshipsResult.fold(
          (_) => null,
          (sponsorships) {
            for (final s in sponsorships) {
              if (s.dog.id == widget.dog.id) return s;
            }
            return null;
          },
        );

        if (!mounted) return;
        if (sponsorship == null) {
          messenger.showSnackBar(
            SnackBar(content: Text("You're now supporting ${widget.dog.name}!")),
          );
        }
        navigator.pop(sponsorship);
      },
    );

    if (mounted) setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final credits = _credits.round();
    final unlocksWeeklyUpdates = credits > 10;

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
              Text('Support ${widget.dog.name}', style: theme.textTheme.headlineSmall),
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
                unlocksWeeklyUpdates
                    ? "Weekly video updates from ${widget.dog.name}'s handler unlocked!"
                    : 'Sponsoring more than \$10/mo unlocks weekly video updates '
                        "from ${widget.dog.name}'s handler.",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: unlocksWeeklyUpdates ? AppColors.ink : AppColors.bodyGray,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                "Pledged credits are permanent and can't be moved to another dog.",
                style: theme.textTheme.bodySmall?.copyWith(color: AppColors.bodyGray),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: NeoButton(
                  onPressed: _isSubmitting ? null : _confirm,
                  child: Text('Pledge \$$credits/mo to ${widget.dog.name}'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
