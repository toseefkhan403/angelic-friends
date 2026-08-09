import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:sponsor_a_dog/core/error/failures.dart';

abstract class UseCase<Success, Params> {
  Future<Either<Failure, Success>> call(Params params);
}

class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
