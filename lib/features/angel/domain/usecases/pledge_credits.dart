import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:sponsor_a_dog/core/error/failures.dart';
import 'package:sponsor_a_dog/core/usecase/usecase.dart';
import 'package:sponsor_a_dog/features/angel/domain/repositories/angel_repository.dart';

class PledgeCreditsParams extends Equatable {
  const PledgeCreditsParams({required this.dogId, required this.credits});

  final String dogId;
  final int credits;

  @override
  List<Object?> get props => [dogId, credits];
}

class PledgeCredits implements UseCase<void, PledgeCreditsParams> {
  const PledgeCredits(this._repository);

  final AngelRepository _repository;

  @override
  Future<Either<Failure, void>> call(PledgeCreditsParams params) {
    return _repository.pledgeCredits(dogId: params.dogId, credits: params.credits);
  }
}
