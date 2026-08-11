import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sponsor_a_dog/features/onboarding/domain/entities/onboarding_slide.dart';

part 'onboarding_slide_model.freezed.dart';
part 'onboarding_slide_model.g.dart';

@freezed
abstract class OnboardingSlideModel with _$OnboardingSlideModel {
  const OnboardingSlideModel._();

  const factory OnboardingSlideModel({
    @JsonKey(name: 'slide_type', fromJson: _slideTypeFromJson, toJson: _slideTypeToJson)
    required OnboardingSlideType slideType,
    required String title,
    required String subtitle,
    @JsonKey(name: 'image_url') String? imageUrl,
    String? eyebrow,
  }) = _OnboardingSlideModel;

  factory OnboardingSlideModel.fromJson(Map<String, dynamic> json) =>
      _$OnboardingSlideModelFromJson(json);

  OnboardingSlide toEntity() => OnboardingSlide(
        slideType: slideType,
        title: title,
        subtitle: subtitle,
        imageUrl: imageUrl,
        eyebrow: eyebrow,
      );
}

OnboardingSlideType _slideTypeFromJson(String value) => switch (value) {
      'who_these_dogs' => OnboardingSlideType.whoTheseDogs,
      'letter' => OnboardingSlideType.letter,
      'marquee_name_capture' => OnboardingSlideType.marqueeNameCapture,
      _ => OnboardingSlideType.hero,
    };

String _slideTypeToJson(OnboardingSlideType type) => switch (type) {
      OnboardingSlideType.hero => 'hero',
      OnboardingSlideType.whoTheseDogs => 'who_these_dogs',
      OnboardingSlideType.letter => 'letter',
      OnboardingSlideType.marqueeNameCapture => 'marquee_name_capture',
    };
