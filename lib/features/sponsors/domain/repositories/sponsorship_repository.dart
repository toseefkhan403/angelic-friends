import 'package:dartz/dartz.dart';
import 'package:sponsor_a_dog/core/error/failures.dart';
import 'package:sponsor_a_dog/features/sponsors/domain/entities/chat_message.dart';
import 'package:sponsor_a_dog/features/sponsors/domain/entities/sponsorship.dart';

abstract class SponsorshipRepository {
  /// The current user's active sponsorships, each with its dog embedded.
  ///
  /// Sponsorships are created server-side only, by the `revenuecat-webhook`
  /// Edge Function reacting to a verified RevenueCat purchase event — the
  /// client has no way to write this table directly (see the RLS policy on
  /// `sponsorships`). After a purchase, the paywall polls this method until
  /// the new row appears rather than writing it itself.
  Future<Either<Failure, List<Sponsorship>>> getMySponsorships();

  /// Full message history for a sponsorship, oldest first. RLS on the
  /// `messages` table means this only ever returns rows for a sponsorship
  /// the current user owns.
  Future<Either<Failure, List<ChatMessage>>> getMessages(String sponsorshipId);

  Future<Either<Failure, ChatMessage>> sendMessage({
    required String sponsorshipId,
    required String text,
  });

  /// Emits each new chat message for [sponsorshipId] as it arrives via
  /// Supabase Realtime, for as long as the returned stream has a listener.
  /// Not wrapped in `Either` — a raw stream, matching the convention used by
  /// `AuthRepository.authStateChanges` for stream-shaped repository methods
  /// in this codebase.
  Stream<ChatMessage> watchNewMessages(String sponsorshipId);
}
