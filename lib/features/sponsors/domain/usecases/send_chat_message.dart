import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:sponsor_a_dog/core/error/failures.dart';
import 'package:sponsor_a_dog/core/usecase/usecase.dart';
import 'package:sponsor_a_dog/features/sponsors/domain/entities/chat_message.dart';
import 'package:sponsor_a_dog/features/sponsors/domain/repositories/sponsorship_repository.dart';

class SendChatMessageParams extends Equatable {
  const SendChatMessageParams({required this.sponsorshipId, required this.text});

  final String sponsorshipId;
  final String text;

  @override
  List<Object?> get props => [sponsorshipId, text];
}

class SendChatMessage implements UseCase<ChatMessage, SendChatMessageParams> {
  const SendChatMessage(this._repository);

  final SponsorshipRepository _repository;

  @override
  Future<Either<Failure, ChatMessage>> call(SendChatMessageParams params) {
    return _repository.sendMessage(sponsorshipId: params.sponsorshipId, text: params.text);
  }
}
