import 'package:dartz/dartz.dart';
import 'package:sponsor_a_dog/core/error/exceptions.dart';
import 'package:sponsor_a_dog/core/error/failures.dart';
import 'package:sponsor_a_dog/features/onboarding/data/datasources/onboarding_remote_data_source.dart';
import 'package:sponsor_a_dog/features/onboarding/domain/entities/onboarding_slide.dart';
import 'package:sponsor_a_dog/features/onboarding/domain/repositories/onboarding_repository.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  const OnboardingRepositoryImpl({required OnboardingRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final OnboardingRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<OnboardingSlide>>> getOnboardingSlides() async {
    try {
      final models = await _remoteDataSource.getOnboardingSlides();
      return Right(models.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
