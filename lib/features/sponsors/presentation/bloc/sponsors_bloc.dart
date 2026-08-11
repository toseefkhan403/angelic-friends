import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sponsor_a_dog/core/usecase/usecase.dart';
import 'package:sponsor_a_dog/features/sponsors/domain/entities/sponsorship.dart';
import 'package:sponsor_a_dog/features/sponsors/domain/usecases/get_my_sponsorships.dart';

part 'sponsors_event.dart';
part 'sponsors_state.dart';

class SponsorsBloc extends Bloc<SponsorsEvent, SponsorsState> {
  SponsorsBloc({required GetMySponsorships getMySponsorships})
      : _getMySponsorships = getMySponsorships,
        super(const SponsorsInitial()) {
    on<SponsorsFetchRequested>(_onFetchRequested);
    on<SponsorsRefreshRequested>(_onFetchRequested);
  }

  final GetMySponsorships _getMySponsorships;

  Future<void> _onFetchRequested(SponsorsEvent event, Emitter<SponsorsState> emit) async {
    emit(const SponsorsLoading());
    final result = await _getMySponsorships(const NoParams());
    result.fold(
      (failure) => emit(SponsorsFailure(failure.message)),
      (sponsorships) => emit(SponsorsLoaded(sponsorships)),
    );
  }
}
