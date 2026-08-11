import 'package:dartz/dartz.dart';
import 'package:sponsor_a_dog/core/error/failures.dart';
import 'package:sponsor_a_dog/core/usecase/usecase.dart';
import 'package:sponsor_a_dog/features/sponsors/domain/entities/chat_message.dart';
import 'package:sponsor_a_dog/features/sponsors/domain/repositories/sponsorship_repository.dart';

class GetChatMessages implements UseCase<List<ChatMessage>, String> {
  const GetChatMessages(this._repository);

  final SponsorshipRepository _repository;

  @override
  Future<Either<Failure, List<ChatMessage>>> call(String sponsorshipId) {
    return _repository.getMessages(sponsorshipId);
  }
}
