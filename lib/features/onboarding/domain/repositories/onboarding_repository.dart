import 'package:dartz/dartz.dart';
import 'package:sponsor_a_dog/core/error/failures.dart';
import 'package:sponsor_a_dog/features/onboarding/domain/entities/onboarding_slide.dart';

abstract class OnboardingRepository {
  Future<Either<Failure, List<OnboardingSlide>>> getOnboardingSlides();
}
