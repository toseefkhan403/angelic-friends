part of 'angel_status_bloc.dart';

sealed class AngelStatusState extends Equatable {
  const AngelStatusState();

  @override
  List<Object?> get props => [];
}

class AngelStatusInitial extends AngelStatusState {
  const AngelStatusInitial();
}

class AngelStatusLoading extends AngelStatusState {
  const AngelStatusLoading();
}

/// [subscription] is `null` when the user has never subscribed.
class AngelStatusLoaded extends AngelStatusState {
  const AngelStatusLoaded(this.subscription);

  final AngelSubscription? subscription;

  @override
  List<Object?> get props => [subscription];
}

class AngelStatusFailure extends AngelStatusState {
  const AngelStatusFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
