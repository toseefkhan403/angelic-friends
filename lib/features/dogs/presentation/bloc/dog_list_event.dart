part of 'dog_list_bloc.dart';

sealed class DogListEvent {
  const DogListEvent();
}

class DogListFetchRequested extends DogListEvent {
  const DogListFetchRequested();
}

class DogListRefreshRequested extends DogListEvent {
  const DogListRefreshRequested();
}
