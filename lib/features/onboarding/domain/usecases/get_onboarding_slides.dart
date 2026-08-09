import 'package:dartz/dartz.dart';
import 'package:sponsor_a_dog/core/error/failures.dart';
import 'package:sponsor_a_dog/core/usecase/usecase.dart';
import 'package:sponsor_a_dog/features/onboarding/domain/entities/onboarding_slide.dart';
import 'package:sponsor_a_dog/features/onboarding/domain/repositories/onboarding_repository.dart';

class GetOnboardingSlides implements UseCase<List<OnboardingSlide>, NoParams> {
  const GetOnboardingSlides(this._repository);

  final OnboardingRepository _repository;

  @override
  Future<Either<Failure, List<OnboardingSlide>>> call(NoParams params) {
    return _repository.getOnboardingSlides();
  }
}
