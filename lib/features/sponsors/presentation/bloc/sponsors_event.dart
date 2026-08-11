part of 'sponsors_bloc.dart';

sealed class SponsorsEvent {
  const SponsorsEvent();
}

class SponsorsFetchRequested extends SponsorsEvent {
  const SponsorsFetchRequested();
}

class SponsorsRefreshRequested extends SponsorsEvent {
  const SponsorsRefreshRequested();
}
