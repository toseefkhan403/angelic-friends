import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:sponsor_a_dog/core/error/exceptions.dart';
import 'package:sponsor_a_dog/core/error/failures.dart';
import 'package:sponsor_a_dog/core/network/network_info.dart';
import 'package:sponsor_a_dog/features/admin/data/datasources/admin_remote_data_source.dart';
import 'package:sponsor_a_dog/features/admin/domain/entities/admin_dog_update_status.dart';
import 'package:sponsor_a_dog/features/admin/domain/entities/admin_sponsorship_overview.dart';
import 'package:sponsor_a_dog/features/admin/domain/repositories/admin_repository.dart';
import 'package:sponsor_a_dog/features/sponsors/domain/entities/chat_message.dart';

class AdminRepositoryImpl implements AdminRepository {
  const AdminRepositoryImpl({
    required AdminRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  final AdminRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, List<AdminSponsorshipOverview>>> getAngelOverviews() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final models = await _remoteDataSource.getAngelOverviews();
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
  Future<Either<Failure, ChatMessage>> sendHandlerReply({
    required String sponsorshipId,
    required String text,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final model =
          await _remoteDataSource.sendHandlerReply(sponsorshipId: sponsorshipId, text: text);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<AdminDogUpdateStatus>>> getDogUpdateStatuses() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final models = await _remoteDataSource.getDogUpdateStatuses();
      return Right(models.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, String>> uploadWeeklyUpdateVideo({
    required String dogId,
    required File videoFile,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final url = await _remoteDataSource.uploadWeeklyUpdateVideo(dogId: dogId, videoFile: videoFile);
      return Right(url);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, int>> sendWeeklyUpdate({
    required String dogId,
    required String mediaUrl,
    String? caption,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final count =
          await _remoteDataSource.sendWeeklyUpdate(dogId: dogId, mediaUrl: mediaUrl, caption: caption);
      return Right(count);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
