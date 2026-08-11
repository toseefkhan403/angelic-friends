import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sponsor_a_dog/features/sponsors/domain/entities/chat_message.dart';
import 'package:sponsor_a_dog/features/sponsors/domain/repositories/sponsorship_repository.dart';
import 'package:sponsor_a_dog/features/sponsors/domain/usecases/get_chat_messages.dart';
import 'package:sponsor_a_dog/features/sponsors/domain/usecases/send_chat_message.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc({
    required GetChatMessages getChatMessages,
    required SendChatMessage sendChatMessage,
    required SponsorshipRepository sponsorshipRepository,
    required this.sponsorshipId,
  })  : _getChatMessages = getChatMessages,
        _sendChatMessage = sendChatMessage,
        _sponsorshipRepository = sponsorshipRepository,
        super(const ChatInitial()) {
    on<ChatFetchRequested>(_onFetchRequested);
    on<ChatMessageSent>(_onMessageSent);
    on<ChatNewMessageReceived>(_onNewMessageReceived);

    _newMessageSubscription = _sponsorshipRepository
        .watchNewMessages(sponsorshipId)
        .listen((message) => add(ChatNewMessageReceived(message)));
  }

  final String sponsorshipId;
  final GetChatMessages _getChatMessages;
  final SendChatMessage _sendChatMessage;
  final SponsorshipRepository _sponsorshipRepository;
  late final StreamSubscription<ChatMessage> _newMessageSubscription;

  Future<void> _onFetchRequested(ChatFetchRequested event, Emitter<ChatState> emit) async {
    emit(const ChatLoading());
    final result = await _getChatMessages(sponsorshipId);
    result.fold(
      (failure) => emit(ChatFailure(failure.message)),
      (messages) => emit(ChatLoaded(messages)),
    );
  }

  Future<void> _onMessageSent(ChatMessageSent event, Emitter<ChatState> emit) async {
    final currentState = state;
    if (currentState is! ChatLoaded || currentState.isSending) return;

    emit(currentState.copyWith(isSending: true, sendErrorMessage: null));
    final result = await _sendChatMessage(
      SendChatMessageParams(sponsorshipId: sponsorshipId, text: event.text),
    );
    result.fold(
      (failure) => emit(currentState.copyWith(isSending: false, sendErrorMessage: failure.message)),
      (message) => emit(
        ChatLoaded([...currentState.messages, message], isSending: false),
      ),
    );
  }

  /// Folds a realtime INSERT into the current message list. The user's own
  /// messages are already appended optimistically by [_onMessageSent] the
  /// moment a send succeeds, and RLS lets a user see their own sent
  /// messages too, so the same message can also arrive here moments later.
  /// De-duping on [ChatMessage.id] handles both that self-echo and any
  /// accidental double-delivery from the realtime channel.
  void _onNewMessageReceived(ChatNewMessageReceived event, Emitter<ChatState> emit) {
    final currentState = state;
    if (currentState is! ChatLoaded) return;
    if (currentState.messages.any((m) => m.id == event.message.id)) return;

    emit(currentState.copyWith(messages: [...currentState.messages, event.message]));
  }

  @override
  Future<void> close() async {
    await _newMessageSubscription.cancel();
    return super.close();
  }
}
