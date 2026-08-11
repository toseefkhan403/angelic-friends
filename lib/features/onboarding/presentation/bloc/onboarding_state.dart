part of 'onboarding_bloc.dart';

enum OnboardingSlidesStatus { loading, loaded, failure }

enum NameSubmitStatus { initial, submitting, success, failure }

@freezed
abstract class OnboardingState with _$OnboardingState {
  const factory OnboardingState({
    @Default(OnboardingSlidesStatus.loading) OnboardingSlidesStatus slidesStatus,
    @Default(<OnboardingSlide>[]) List<OnboardingSlide> slides,
    String? slidesErrorMessage,
    // Supplementary content for the "who these dogs are" and marquee/letter
    // slides. Fetched best-effort alongside the slides: a failure here
    // doesn't block onboarding, the relevant marquees just render empty.
    @Default(<Dog>[]) List<Dog> featuredDogs,
    @Default(<DogUpdateHighlight>[]) List<DogUpdateHighlight> updateHighlights,
    @Default('') String name,
    @Default(NameSubmitStatus.initial) NameSubmitStatus submitStatus,
    String? submitErrorMessage,
  }) = _OnboardingState;
}
