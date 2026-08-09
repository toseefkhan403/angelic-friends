import 'package:dartz/dartz.dart';
import 'package:sponsor_a_dog/core/error/failures.dart';
import 'package:sponsor_a_dog/core/usecase/usecase.dart';
import 'package:sponsor_a_dog/features/dogs/domain/entities/promo_tile.dart';
import 'package:sponsor_a_dog/features/dogs/domain/repositories/dog_repository.dart';

class GetPromoTiles implements UseCase<List<PromoTile>, NoParams> {
  const GetPromoTiles(this._repository);

  final DogRepository _repository;

  @override
  Future<Either<Failure, List<PromoTile>>> call(NoParams params) {
    return _repository.getPromoTiles();
  }
}
