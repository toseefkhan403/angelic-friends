import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sponsor_a_dog/core/usecase/usecase.dart';
import 'package:sponsor_a_dog/features/dogs/domain/entities/dog.dart';
import 'package:sponsor_a_dog/features/dogs/domain/entities/promo_tile.dart';
import 'package:sponsor_a_dog/features/dogs/domain/usecases/get_dogs.dart';
import 'package:sponsor_a_dog/features/dogs/domain/usecases/get_promo_tiles.dart';

part 'dog_list_event.dart';
part 'dog_list_state.dart';

class DogListBloc extends Bloc<DogListEvent, DogListState> {
  DogListBloc({required GetDogs getDogs, required GetPromoTiles getPromoTiles})
      : _getDogs = getDogs,
        _getPromoTiles = getPromoTiles,
        super(const DogListInitial()) {
    on<DogListFetchRequested>(_onFetchRequested);
    on<DogListRefreshRequested>(_onFetchRequested);
  }

  final GetDogs _getDogs;
  final GetPromoTiles _getPromoTiles;

  Future<void> _onFetchRequested(
    DogListEvent event,
    Emitter<DogListState> emit,
  ) async {
    emit(const DogListLoading());

    final dogsFuture = _getDogs(const NoParams());
    final promoTilesFuture = _getPromoTiles(const NoParams());
    final dogsResult = await dogsFuture;
    final promoTilesResult = await promoTilesFuture;

    dogsResult.fold(
      (failure) => emit(DogListFailure(failure.message)),
      (dogs) => promoTilesResult.fold(
        (failure) => emit(DogListFailure(failure.message)),
        (promoTiles) => emit(DogListLoaded(dogs, promoTiles)),
      ),
    );
  }
}
