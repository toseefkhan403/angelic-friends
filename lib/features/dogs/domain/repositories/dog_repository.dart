import 'package:dartz/dartz.dart';
import 'package:sponsor_a_dog/core/error/failures.dart';
import 'package:sponsor_a_dog/features/dogs/domain/entities/dog.dart';
import 'package:sponsor_a_dog/features/dogs/domain/entities/dog_detail.dart';
import 'package:sponsor_a_dog/features/dogs/domain/entities/dog_update_highlight.dart';
import 'package:sponsor_a_dog/features/dogs/domain/entities/promo_tile.dart';

abstract class DogRepository {
  Future<Either<Failure, List<Dog>>> getDogs();
  Future<Either<Failure, List<PromoTile>>> getPromoTiles();
  Future<Either<Failure, DogDetail>> getDogDetail(String dogId);

  /// Captioned media rows (`dog_media.caption is not null`) paired with
  /// their dog's name/care tag, for onboarding's "real updates" marquee.
  Future<Either<Failure, List<DogUpdateHighlight>>> getFeaturedDogUpdates();
}
