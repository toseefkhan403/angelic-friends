part of 'chat_bloc.dart';

sealed class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatLoaded extends ChatState {
  const ChatLoaded(this.messages, {this.isSending = false, this.sendErrorMessage});

  final List<ChatMessage> messages;
  final bool isSending;
  final String? sendErrorMessage;

  ChatLoaded copyWith({List<ChatMessage>? messages, bool? isSending, String? sendErrorMessage}) {
    return ChatLoaded(
      messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      sendErrorMessage: sendErrorMessage,
    );
  }

  @override
  List<Object?> get props => [messages, isSending, sendErrorMessage];
}

class ChatFailure extends ChatState {
  const ChatFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
