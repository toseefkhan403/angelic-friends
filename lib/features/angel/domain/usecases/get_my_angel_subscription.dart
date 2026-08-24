import 'package:dartz/dartz.dart';
import 'package:sponsor_a_dog/core/error/failures.dart';
import 'package:sponsor_a_dog/core/usecase/usecase.dart';
import 'package:sponsor_a_dog/features/angel/domain/entities/angel_subscription.dart';
import 'package:sponsor_a_dog/features/angel/domain/repositories/angel_repository.dart';

class GetMyAngelSubscription implements UseCase<AngelSubscription?, NoParams> {
  const GetMyAngelSubscription(this._repository);

  final AngelRepository _repository;

  @override
  Future<Either<Failure, AngelSubscription?>> call(NoParams params) {
    return _repository.getMySubscription();
  }
}
