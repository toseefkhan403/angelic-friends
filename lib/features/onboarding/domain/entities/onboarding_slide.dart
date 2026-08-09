import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_slide.freezed.dart';

@freezed
abstract class OnboardingSlide with _$OnboardingSlide {
  const factory OnboardingSlide({
    required String title,
    required String subtitle,
    required String imageUrl,
  }) = _OnboardingSlide;
}
