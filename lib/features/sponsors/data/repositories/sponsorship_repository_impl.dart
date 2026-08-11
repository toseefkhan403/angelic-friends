import 'package:dartz/dartz.dart';
import 'package:sponsor_a_dog/core/error/exceptions.dart';
import 'package:sponsor_a_dog/core/error/failures.dart';
import 'package:sponsor_a_dog/core/network/network_info.dart';
import 'package:sponsor_a_dog/features/sponsors/data/datasources/sponsorship_remote_data_source.dart';
import 'package:sponsor_a_dog/features/sponsors/domain/entities/chat_message.dart';
import 'package:sponsor_a_dog/features/sponsors/domain/entities/sponsorship.dart';
import 'package:sponsor_a_dog/features/sponsors/domain/repositories/sponsorship_repository.dart';

class SponsorshipRepositoryImpl implements SponsorshipRepository {
  const SponsorshipRepositoryImpl({
    required SponsorshipRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  final SponsorshipRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, List<Sponsorship>>> getMySponsorships() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final models = await _remoteDataSource.getMySponsorships();
      return Right(models.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<ChatMessage>>> getMessages(String sponsorshipId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final models = await _remoteDataSource.getMessages(sponsorshipId);
      return Right(models.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, ChatMessage>> sendMessage({
    required String sponsorshipId,
    required String text,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final model = await _remoteDataSource.sendMessage(sponsorshipId: sponsorshipId, text: text);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Stream<ChatMessage> watchNewMessages(String sponsorshipId) {
    return _remoteDataSource
        .watchNewMessages(sponsorshipId)
        .map((model) => model.toEntity());
  }
}
