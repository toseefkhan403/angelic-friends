part of 'dog_detail_bloc.dart';

sealed class DogDetailEvent {
  const DogDetailEvent();
}

class DogDetailFetchRequested extends DogDetailEvent {
  const DogDetailFetchRequested(this.dogId);

  final String dogId;
}
