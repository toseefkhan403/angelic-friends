part of 'sponsors_bloc.dart';

sealed class SponsorsState extends Equatable {
  const SponsorsState();

  @override
  List<Object?> get props => [];
}

class SponsorsInitial extends SponsorsState {
  const SponsorsInitial();
}

class SponsorsLoading extends SponsorsState {
  const SponsorsLoading();
}

class SponsorsLoaded extends SponsorsState {
  const SponsorsLoaded(this.sponsorships);

  final List<Sponsorship> sponsorships;

  @override
  List<Object?> get props => [sponsorships];
}

class SponsorsFailure extends SponsorsState {
  const SponsorsFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
