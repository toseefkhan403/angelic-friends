import 'package:dartz/dartz.dart';
import 'package:sponsor_a_dog/core/error/failures.dart';
import 'package:sponsor_a_dog/features/angel/domain/entities/angel_subscription.dart';

abstract class AngelRepository {
  /// Returns `null` (inside `Right`) if the current user has never
  /// subscribed — not a failure case.
  Future<Either<Failure, AngelSubscription?>> getMySubscription();

  /// Locks [credits] from the user's available balance onto [dogId],
  /// permanently — see `pledge_credits` in the Supabase migration. Errors
  /// (insufficient balance, no active subscription, etc.) surface as
  /// user-facing [Failure.message] text from the RPC itself.
  Future<Either<Failure, void>> pledgeCredits({
    required String dogId,
    required int credits,
  });
}
