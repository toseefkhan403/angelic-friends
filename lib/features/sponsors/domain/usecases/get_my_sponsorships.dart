import 'package:dartz/dartz.dart';
import 'package:sponsor_a_dog/core/error/failures.dart';
import 'package:sponsor_a_dog/core/usecase/usecase.dart';
import 'package:sponsor_a_dog/features/sponsors/domain/entities/sponsorship.dart';
import 'package:sponsor_a_dog/features/sponsors/domain/repositories/sponsorship_repository.dart';

class GetMySponsorships implements UseCase<List<Sponsorship>, NoParams> {
  const GetMySponsorships(this._repository);

  final SponsorshipRepository _repository;

  @override
  Future<Either<Failure, List<Sponsorship>>> call(NoParams params) {
    return _repository.getMySponsorships();
  }
}
