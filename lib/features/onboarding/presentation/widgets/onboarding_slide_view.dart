import 'package:flutter/material.dart';
import 'package:sponsor_a_dog/features/dogs/domain/entities/dog_update_highlight.dart';
import 'package:sponsor_a_dog/features/onboarding/domain/entities/onboarding_slide.dart';
import 'package:sponsor_a_dog/features/onboarding/presentation/widgets/slides/hero_slide.dart';
import 'package:sponsor_a_dog/features/onboarding/presentation/widgets/slides/letter_slide.dart';
import 'package:sponsor_a_dog/features/onboarding/presentation/widgets/slides/marquee_name_capture_slide.dart';
import 'package:sponsor_a_dog/features/onboarding/presentation/widgets/slides/who_these_dogs_slide.dart';

/// Dispatches to the right layout for [slide.slideType]. Each layout is a
/// distinct template (hero image, dog marquee, letter card, name field)
/// rather than one generic image/title/subtitle shape.
class OnboardingSlideView extends StatelessWidget {
  const OnboardingSlideView({
    required this.slide,
    required this.isActive,
    required this.updateHighlights,
    required this.nameController,
    required this.onNameChanged,
    super.key,
  });

  final OnboardingSlide slide;
  final bool isActive;
  final List<DogUpdateHighlight> updateHighlights;
  final TextEditingController nameController;
  final ValueChanged<String> onNameChanged;

  @override
  Widget build(BuildContext context) {
    return switch (slide.slideType) {
      OnboardingSlideType.hero => HeroSlide(slide: slide),
      OnboardingSlideType.whoTheseDogs =>
        WhoTheseDogsSlide(slide: slide, highlights: updateHighlights),
      OnboardingSlideType.letter => LetterSlide(
          slide: slide,
          highlights: updateHighlights,
          isActive: isActive,
        ),
      OnboardingSlideType.marqueeNameCapture => MarqueeNameCaptureSlide(
          slide: slide,
          nameController: nameController,
          onNameChanged: onNameChanged,
        ),
    };
  }
}
