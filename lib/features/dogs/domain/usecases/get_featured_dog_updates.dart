import 'package:dartz/dartz.dart';
import 'package:sponsor_a_dog/core/error/failures.dart';
import 'package:sponsor_a_dog/core/usecase/usecase.dart';
import 'package:sponsor_a_dog/features/dogs/domain/entities/dog_update_highlight.dart';
import 'package:sponsor_a_dog/features/dogs/domain/repositories/dog_repository.dart';

class GetFeaturedDogUpdates implements UseCase<List<DogUpdateHighlight>, NoParams> {
  const GetFeaturedDogUpdates(this._repository);

  final DogRepository _repository;

  @override
  Future<Either<Failure, List<DogUpdateHighlight>>> call(NoParams params) {
    return _repository.getFeaturedDogUpdates();
  }
}
