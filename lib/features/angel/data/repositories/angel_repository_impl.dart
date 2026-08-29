import 'package:dartz/dartz.dart';
import 'package:sponsor_a_dog/core/error/exceptions.dart';
import 'package:sponsor_a_dog/core/error/failures.dart';
import 'package:sponsor_a_dog/core/network/network_info.dart';
import 'package:sponsor_a_dog/features/angel/data/datasources/angel_remote_data_source.dart';
import 'package:sponsor_a_dog/features/angel/domain/entities/angel_subscription.dart';
import 'package:sponsor_a_dog/features/angel/domain/entities/feeding_pledge.dart';
import 'package:sponsor_a_dog/features/angel/domain/repositories/angel_repository.dart';

class AngelRepositoryImpl implements AngelRepository {
  const AngelRepositoryImpl({
    required AngelRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  final AngelRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, AngelSubscription?>> getMySubscription() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final model = await _remoteDataSource.getMySubscription();
      return Right(model?.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> pledgeCredits({
    required String dogId,
    required int credits,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      await _remoteDataSource.pledgeCredits(dogId: dogId, credits: credits);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> pledgeCreditsToFeeding({required int credits}) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      await _remoteDataSource.pledgeCreditsToFeeding(credits: credits);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<FeedingPledge>>> getMyFeedingPledges() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final models = await _remoteDataSource.getMyFeedingPledges();
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
