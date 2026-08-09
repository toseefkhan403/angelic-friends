part of 'onboarding_bloc.dart';

@freezed
sealed class OnboardingEvent with _$OnboardingEvent {
  const factory OnboardingEvent.started() = OnboardingStarted;
  const factory OnboardingEvent.nameChanged(String name) = OnboardingNameChanged;
  const factory OnboardingEvent.submitted() = OnboardingSubmitted;
}
