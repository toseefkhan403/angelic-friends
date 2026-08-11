// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_slide_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OnboardingSlideModel _$OnboardingSlideModelFromJson(
  Map<String, dynamic> json,
) => _OnboardingSlideModel(
  slideType: _slideTypeFromJson(json['slide_type'] as String),
  title: json['title'] as String,
  subtitle: json['subtitle'] as String,
  imageUrl: json['image_url'] as String?,
  eyebrow: json['eyebrow'] as String?,
);

Map<String, dynamic> _$OnboardingSlideModelToJson(
  _OnboardingSlideModel instance,
) => <String, dynamic>{
  'slide_type': _slideTypeToJson(instance.slideType),
  'title': instance.title,
  'subtitle': instance.subtitle,
  'image_url': instance.imageUrl,
  'eyebrow': instance.eyebrow,
};
