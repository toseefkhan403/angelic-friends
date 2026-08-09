import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sponsor_a_dog/features/onboarding/domain/entities/onboarding_slide.dart';

part 'onboarding_slide_model.freezed.dart';
part 'onboarding_slide_model.g.dart';

@freezed
abstract class OnboardingSlideModel with _$OnboardingSlideModel {
  const OnboardingSlideModel._();

  const factory OnboardingSlideModel({
    required String title,
    required String subtitle,
    @JsonKey(name: 'image_url') required String imageUrl,
  }) = _OnboardingSlideModel;

  factory OnboardingSlideModel.fromJson(Map<String, dynamic> json) =>
      _$OnboardingSlideModelFromJson(json);

  OnboardingSlide toEntity() =>
      OnboardingSlide(title: title, subtitle: subtitle, imageUrl: imageUrl);
}
