import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sponsor_a_dog/features/dogs/domain/entities/dog_detail.dart';
import 'package:sponsor_a_dog/features/dogs/domain/usecases/get_dog_detail.dart';

part 'dog_detail_event.dart';
part 'dog_detail_state.dart';

class DogDetailBloc extends Bloc<DogDetailEvent, DogDetailState> {
  DogDetailBloc({required GetDogDetail getDogDetail})
      : _getDogDetail = getDogDetail,
        super(const DogDetailInitial()) {
    on<DogDetailFetchRequested>(_onFetchRequested);
  }

  final GetDogDetail _getDogDetail;

  Future<void> _onFetchRequested(
    DogDetailFetchRequested event,
    Emitter<DogDetailState> emit,
  ) async {
    emit(const DogDetailLoading());

    final result = await _getDogDetail(event.dogId);

    result.fold(
      (failure) => emit(DogDetailFailure(failure.message)),
      (detail) => emit(DogDetailLoaded(detail)),
    );
  }
}
