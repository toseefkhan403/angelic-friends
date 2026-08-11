import 'package:dartz/dartz.dart';
import 'package:sponsor_a_dog/core/error/exceptions.dart';
import 'package:sponsor_a_dog/core/error/failures.dart';
import 'package:sponsor_a_dog/core/network/network_info.dart';
import 'package:sponsor_a_dog/features/dogs/data/datasources/dog_remote_data_source.dart';
import 'package:sponsor_a_dog/features/dogs/data/models/dog_media_model.dart';
import 'package:sponsor_a_dog/features/dogs/data/models/dog_model.dart';
import 'package:sponsor_a_dog/features/dogs/data/models/shelter_model.dart';
import 'package:sponsor_a_dog/features/dogs/data/models/sponsorship_impact_model.dart';
import 'package:sponsor_a_dog/features/dogs/domain/entities/dog.dart';
import 'package:sponsor_a_dog/features/dogs/domain/entities/dog_detail.dart';
import 'package:sponsor_a_dog/features/dogs/domain/entities/dog_update_highlight.dart';
import 'package:sponsor_a_dog/features/dogs/domain/entities/promo_tile.dart';
import 'package:sponsor_a_dog/features/dogs/domain/repositories/dog_repository.dart';

class DogRepositoryImpl implements DogRepository {
  const DogRepositoryImpl({
    required DogRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  final DogRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, List<Dog>>> getDogs() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final models = await _remoteDataSource.getDogs();
      return Right(models.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<PromoTile>>> getPromoTiles() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final models = await _remoteDataSource.getPromoTiles();
      return Right(models.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, DogDetail>> getDogDetail(String dogId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final row = await _remoteDataSource.getDogDetail(dogId);

      final dog = DogModel.fromJson(row).toEntity();

      final mediaModels = (row['dog_media'] as List<dynamic>?)
              ?.map((json) => DogMediaModel.fromJson(json as Map<String, dynamic>))
              .toList() ??
          <DogMediaModel>[];
      mediaModels.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      final shelterJson = row['shelters'] as Map<String, dynamic>?;
      final shelter = shelterJson == null ? null : ShelterModel.fromJson(shelterJson).toEntity();

      final impactModels = (row['sponsorship_impacts'] as List<dynamic>?)
              ?.map((json) => SponsorshipImpactModel.fromJson(json as Map<String, dynamic>))
              .toList() ??
          <SponsorshipImpactModel>[];
      impactModels.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      return Right(
        DogDetail(
          dog: dog,
          media: mediaModels.map((model) => model.toEntity()).toList(),
          shelter: shelter,
          impacts: impactModels.map((model) => model.toEntity()).toList(),
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<DogUpdateHighlight>>> getFeaturedDogUpdates() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final rows = await _remoteDataSource.getFeaturedMedia();
      final highlights = rows.map((row) {
        final dogJson = row['dogs'] as Map<String, dynamic>?;
        return DogUpdateHighlight(
          dogName: dogJson?['name'] as String? ?? '',
          careTag: dogJson?['care_tag'] as String?,
          media: DogMediaModel.fromJson(row).toEntity(),
        );
      }).toList();
      return Right(highlights);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
