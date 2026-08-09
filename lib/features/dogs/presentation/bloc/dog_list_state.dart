part of 'dog_list_bloc.dart';

sealed class DogListState extends Equatable {
  const DogListState();

  @override
  List<Object?> get props => [];
}

class DogListInitial extends DogListState {
  const DogListInitial();
}

class DogListLoading extends DogListState {
  const DogListLoading();
}

class DogListLoaded extends DogListState {
  const DogListLoaded(this.dogs, this.promoTiles);

  final List<Dog> dogs;
  final List<PromoTile> promoTiles;

  @override
  List<Object?> get props => [dogs, promoTiles];
}

class DogListFailure extends DogListState {
  const DogListFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
