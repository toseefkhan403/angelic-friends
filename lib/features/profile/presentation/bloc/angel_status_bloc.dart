import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sponsor_a_dog/core/usecase/usecase.dart';
import 'package:sponsor_a_dog/features/angel/domain/entities/angel_subscription.dart';
import 'package:sponsor_a_dog/features/angel/domain/usecases/get_my_angel_subscription.dart';

part 'angel_status_event.dart';
part 'angel_status_state.dart';

/// Fetches the current user's Angel subscription for display on the Profile
/// tab (available/monthly credits, or a "become an Angel" prompt).
class AngelStatusBloc extends Bloc<AngelStatusEvent, AngelStatusState> {
  AngelStatusBloc({required GetMyAngelSubscription getMyAngelSubscription})
      : _getMyAngelSubscription = getMyAngelSubscription,
        super(const AngelStatusInitial()) {
    on<AngelStatusFetchRequested>(_onFetchRequested);
  }

  final GetMyAngelSubscription _getMyAngelSubscription;

  Future<void> _onFetchRequested(
    AngelStatusFetchRequested event,
    Emitter<AngelStatusState> emit,
  ) async {
    emit(const AngelStatusLoading());
    final result = await _getMyAngelSubscription(const NoParams());
    result.fold(
      (failure) => emit(AngelStatusFailure(failure.message)),
      (subscription) => emit(AngelStatusLoaded(subscription)),
    );
  }
}
