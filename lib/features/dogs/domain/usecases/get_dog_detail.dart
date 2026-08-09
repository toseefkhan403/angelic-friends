import 'package:dartz/dartz.dart';
import 'package:sponsor_a_dog/core/error/failures.dart';
import 'package:sponsor_a_dog/core/usecase/usecase.dart';
import 'package:sponsor_a_dog/features/dogs/domain/entities/dog_detail.dart';
import 'package:sponsor_a_dog/features/dogs/domain/repositories/dog_repository.dart';

class GetDogDetail implements UseCase<DogDetail, String> {
  const GetDogDetail(this._repository);

  final DogRepository _repository;

  @override
  Future<Either<Failure, DogDetail>> call(String params) {
    return _repository.getDogDetail(params);
  }
}
