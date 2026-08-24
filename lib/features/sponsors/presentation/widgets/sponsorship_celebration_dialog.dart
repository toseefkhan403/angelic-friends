import 'package:brutalist_ui/brutalist_ui.dart' show NeoBox, NeoButton;
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:sponsor_a_dog/core/constants/app_spacing.dart';
import 'package:sponsor_a_dog/core/theme/app_colors.dart';
import 'package:sponsor_a_dog/features/sponsors/domain/entities/sponsorship.dart';
import 'package:sponsor_a_dog/features/sponsors/presentation/pages/chat_detail_page.dart';

/// Celebratory dialog shown right after a credit pledge succeeds — confetti
/// burst, a congratulatory message, and a shortcut straight into the chat
/// with [sponsorship]'s dog's handler.
Future<void> showSponsorshipCelebrationDialog(
  BuildContext context, {
  required Sponsorship sponsorship,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => _SponsorshipCelebrationDialog(sponsorship: sponsorship),
  );
}

class _SponsorshipCelebrationDialog extends StatefulWidget {
  const _SponsorshipCelebrationDialog({required this.sponsorship});

  final Sponsorship sponsorship;

  @override
  State<_SponsorshipCelebrationDialog> createState() =>
      _SponsorshipCelebrationDialogState();
}

class _SponsorshipCelebrationDialogState extends State<_SponsorshipCelebrationDialog> {
  late final ConfettiController _confettiController =
      ConfettiController(duration: const Duration(seconds: 2));

  @override
  void initState() {
    super.initState();
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dog = widget.sponsorship.dog;
    final navigator = Navigator.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppSpacing.lg),
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          NeoBox(
            color: AppColors.ground,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎉', style: TextStyle(fontSize: 40)),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  "You're now supporting ${dog.name}!",
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  "Thank you for being an Angel — ${dog.name}'s handler can "
                  'now chat with you directly.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.bodyGray),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: NeoButton(
                    onPressed: () {
                      navigator.pop();
                      navigator.push(
                        MaterialPageRoute(
                          builder: (_) => ChatDetailPage(sponsorship: widget.sponsorship),
                        ),
                      );
                    },
                    child: Text("Chat with ${dog.name}'s handler"),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                TextButton(
                  onPressed: () => navigator.pop(),
                  child: const Text('Maybe later'),
                ),
              ],
            ),
          ),
          Positioned(
            top: -16,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              maxBlastForce: 40,
              minBlastForce: 20,
              emissionFrequency: 0.02,
              numberOfParticles: 8,
              gravity: 0.3,
              colors: const [AppColors.mustard, AppColors.ink, Colors.white],
            ),
          ),
        ],
      ),
    );
  }
}
