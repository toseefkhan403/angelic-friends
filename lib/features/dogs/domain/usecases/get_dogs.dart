import 'package:dartz/dartz.dart';
import 'package:sponsor_a_dog/core/error/failures.dart';
import 'package:sponsor_a_dog/core/usecase/usecase.dart';
import 'package:sponsor_a_dog/features/dogs/domain/entities/dog.dart';
import 'package:sponsor_a_dog/features/dogs/domain/repositories/dog_repository.dart';

class GetDogs implements UseCase<List<Dog>, NoParams> {
  const GetDogs(this._repository);

  final DogRepository _repository;

  @override
  Future<Either<Failure, List<Dog>>> call(NoParams params) {
    return _repository.getDogs();
  }
}
