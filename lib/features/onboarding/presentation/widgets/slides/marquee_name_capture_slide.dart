import 'package:brutalist_ui/brutalist_ui.dart' show NeoTextField;
import 'package:flutter/material.dart';
import 'package:sponsor_a_dog/core/constants/app_spacing.dart';
import 'package:sponsor_a_dog/features/onboarding/domain/entities/onboarding_slide.dart';
import 'package:sponsor_a_dog/features/onboarding/presentation/widgets/slides/slide_eyebrow.dart';

/// Final onboarding slide: eyebrow/title/subtitle, then the name field that
/// doubles as this app's login step.
class MarqueeNameCaptureSlide extends StatelessWidget {
  const MarqueeNameCaptureSlide({
    required this.slide,
    required this.nameController,
    required this.onNameChanged,
    super.key,
  });

  final OnboardingSlide slide;
  final TextEditingController nameController;
  final ValueChanged<String> onNameChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (slide.eyebrow != null) SlideEyebrow(text: slide.eyebrow!),
            const SizedBox(height: AppSpacing.sm),
            Text(
              slide.title,
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              slide.subtitle,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: NeoTextField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                placeholder: 'Your name',
                onChanged: onNameChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
