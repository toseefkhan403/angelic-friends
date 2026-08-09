part of 'dog_detail_bloc.dart';

sealed class DogDetailState extends Equatable {
  const DogDetailState();

  @override
  List<Object?> get props => [];
}

class DogDetailInitial extends DogDetailState {
  const DogDetailInitial();
}

class DogDetailLoading extends DogDetailState {
  const DogDetailLoading();
}

class DogDetailLoaded extends DogDetailState {
  const DogDetailLoaded(this.detail);

  final DogDetail detail;

  @override
  List<Object?> get props => [detail];
}

class DogDetailFailure extends DogDetailState {
  const DogDetailFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
