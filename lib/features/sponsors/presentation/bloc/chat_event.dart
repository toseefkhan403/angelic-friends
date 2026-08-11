part of 'chat_bloc.dart';

sealed class ChatEvent {
  const ChatEvent();
}

class ChatFetchRequested extends ChatEvent {
  const ChatFetchRequested();
}

class ChatMessageSent extends ChatEvent {
  const ChatMessageSent(this.text);

  final String text;
}

/// Fired internally when a new message arrives over the realtime
/// subscription started in [ChatBloc]'s constructor. Never dispatched from
/// the UI.
class ChatNewMessageReceived extends ChatEvent {
  const ChatNewMessageReceived(this.message);

  final ChatMessage message;
}
