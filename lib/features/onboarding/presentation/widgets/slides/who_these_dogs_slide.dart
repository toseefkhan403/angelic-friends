import 'package:flutter/material.dart';
import 'package:sponsor_a_dog/core/constants/app_spacing.dart';
import 'package:sponsor_a_dog/core/widgets/auto_scrolling_row.dart';
import 'package:sponsor_a_dog/features/dogs/domain/entities/dog.dart';
import 'package:sponsor_a_dog/features/dogs/presentation/widgets/explore_dog_card.dart';
import 'package:sponsor_a_dog/features/onboarding/domain/entities/onboarding_slide.dart';
import 'package:sponsor_a_dog/features/onboarding/presentation/widgets/slides/slide_eyebrow.dart';

/// "Who these dogs are" slide: eyebrow/title/subtitle, an auto-scrolling
/// marquee of real dog cards, then a short list of what sponsorship funds.
class WhoTheseDogsSlide extends StatelessWidget {
  const WhoTheseDogsSlide({required this.slide, required this.dogs, super.key});

  final OnboardingSlide slide;
  final List<Dog> dogs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (slide.eyebrow != null) SlideEyebrow(text: slide.eyebrow!),
          const SizedBox(height: AppSpacing.sm),
          Text(slide.title, style: theme.textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            slide.subtitle,
            style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (dogs.isNotEmpty)
            SizedBox(
              height: 260,
              child: AutoScrollingRow(
                itemCount: dogs.length,
                itemWidth: 150,
                itemBuilder: (context, index) =>
                    IgnorePointer(child: ExploreDogCard(dog: dogs[index])),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          const _ImpactRow(emoji: '❤️', text: 'Funds real medical care, not overhead'),
          const _ImpactRow(emoji: '🌙', text: 'Pays for their bed, meds, and quiet comfort'),
          const _ImpactRow(emoji: '🛡️', text: 'Keeps a long-term resident from being forgotten'),
        ],
      ),
    );
  }
}

class _ImpactRow extends StatelessWidget {
  const _ImpactRow({required this.emoji, required this.text});

  final String emoji;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
