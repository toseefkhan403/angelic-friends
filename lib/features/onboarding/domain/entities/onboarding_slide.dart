import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_slide.freezed.dart';

enum OnboardingSlideType { hero, whoTheseDogs, letter, marqueeNameCapture }

@freezed
abstract class OnboardingSlide with _$OnboardingSlide {
  const factory OnboardingSlide({
    required OnboardingSlideType slideType,
    required String title,
    required String subtitle,
    String? imageUrl,
    String? eyebrow,
  }) = _OnboardingSlide;
}
