import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sponsor_a_dog/core/analytics/analytics_service.dart';
import 'package:sponsor_a_dog/core/auth/auth_repository.dart';
import 'package:sponsor_a_dog/core/error/failures.dart';
import 'package:sponsor_a_dog/core/usecase/usecase.dart';
import 'package:sponsor_a_dog/features/dogs/domain/entities/dog.dart';
import 'package:sponsor_a_dog/features/dogs/domain/entities/dog_update_highlight.dart';
import 'package:sponsor_a_dog/features/dogs/domain/usecases/get_dogs.dart';
import 'package:sponsor_a_dog/features/dogs/domain/usecases/get_featured_dog_updates.dart';
import 'package:sponsor_a_dog/features/onboarding/domain/entities/onboarding_slide.dart';
import 'package:sponsor_a_dog/features/onboarding/domain/usecases/get_onboarding_slides.dart';

part 'onboarding_bloc.freezed.dart';
part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc({
    required GetOnboardingSlides getOnboardingSlides,
    required GetDogs getDogs,
    required GetFeaturedDogUpdates getFeaturedDogUpdates,
    required AuthRepository authRepository,
    required AnalyticsService analytics,
  })  : _getOnboardingSlides = getOnboardingSlides,
        _getDogs = getDogs,
        _getFeaturedDogUpdates = getFeaturedDogUpdates,
        _authRepository = authRepository,
        _analytics = analytics,
        super(const OnboardingState()) {
    on<OnboardingStarted>(_onStarted);
    on<OnboardingNameChanged>(_onNameChanged);
    on<OnboardingSubmitted>(_onSubmitted);
  }

  final GetOnboardingSlides _getOnboardingSlides;
  final GetDogs _getDogs;
  final GetFeaturedDogUpdates _getFeaturedDogUpdates;
  final AuthRepository _authRepository;
  final AnalyticsService _analytics;

  Future<void> _onStarted(OnboardingStarted event, Emitter<OnboardingState> emit) async {
    emit(state.copyWith(slidesStatus: OnboardingSlidesStatus.loading));

    final results = await Future.wait<dynamic>([
      _getOnboardingSlides(const NoParams()),
      _getDogs(const NoParams()),
      _getFeaturedDogUpdates(const NoParams()),
    ]);

    final slidesResult = results[0] as Either<Failure, List<OnboardingSlide>>;
    final dogsResult = results[1] as Either<Failure, List<Dog>>;
    final updatesResult = results[2] as Either<Failure, List<DogUpdateHighlight>>;

    slidesResult.fold(
      (failure) => emit(state.copyWith(
        slidesStatus: OnboardingSlidesStatus.failure,
        slidesErrorMessage: failure.message,
      )),
      (slides) => emit(state.copyWith(
        slidesStatus: OnboardingSlidesStatus.loaded,
        slides: slides,
        // Supplementary marquees degrade gracefully to an empty list on
        // failure rather than blocking onboarding on a non-critical fetch.
        featuredDogs: dogsResult.getOrElse(() => const []),
        updateHighlights: updatesResult.getOrElse(() => const []),
      )),
    );
  }

  void _onNameChanged(OnboardingNameChanged event, Emitter<OnboardingState> emit) {
    emit(state.copyWith(name: event.name, submitStatus: NameSubmitStatus.initial));
  }

  Future<void> _onSubmitted(
    OnboardingSubmitted event,
    Emitter<OnboardingState> emit,
  ) async {
    final trimmedName = state.name.trim();
    if (trimmedName.isEmpty) {
      emit(state.copyWith(
        submitStatus: NameSubmitStatus.failure,
        submitErrorMessage: 'Tell us what to call you.',
      ));
      return;
    }

    emit(state.copyWith(submitStatus: NameSubmitStatus.submitting));
    final result = await _authRepository.signInAnonymouslyWithName(trimmedName);
    result.fold(
      (failure) => emit(state.copyWith(
        submitStatus: NameSubmitStatus.failure,
        submitErrorMessage: failure.message,
      )),
      (_) {
        _analytics.logEvent('onboarding_complete');
        emit(state.copyWith(submitStatus: NameSubmitStatus.success));
      },
    );
  }
}
