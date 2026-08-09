part of 'onboarding_bloc.dart';

enum OnboardingSlidesStatus { loading, loaded, failure }

enum NameSubmitStatus { initial, submitting, success, failure }

@freezed
abstract class OnboardingState with _$OnboardingState {
  const factory OnboardingState({
    @Default(OnboardingSlidesStatus.loading) OnboardingSlidesStatus slidesStatus,
    @Default(<OnboardingSlide>[]) List<OnboardingSlide> slides,
    String? slidesErrorMessage,
    @Default('') String name,
    @Default(NameSubmitStatus.initial) NameSubmitStatus submitStatus,
    String? submitErrorMessage,
  }) = _OnboardingState;
}
