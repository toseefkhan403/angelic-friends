part of 'angel_status_bloc.dart';

sealed class AngelStatusEvent {
  const AngelStatusEvent();
}

class AngelStatusFetchRequested extends AngelStatusEvent {
  const AngelStatusFetchRequested();
}
