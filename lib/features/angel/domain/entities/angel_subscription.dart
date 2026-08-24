import 'package:equatable/equatable.dart';

enum AngelSubscriptionStatus { active, cancelled }

/// The current user's "Become an Angel" subscription state. `null` (not this
/// class) represents "never subscribed" — see [AngelRepository.getMySubscription].
class AngelSubscription extends Equatable {
  const AngelSubscription({
    required this.monthlyCredits,
    required this.availableCredits,
    required this.status,
  });

  /// Credits granted per billing cycle at the subscriber's current tier.
  final int monthlyCredits;

  /// Unallocated balance, rolled over from prior cycles, available to
  /// pledge to dogs via `pledge_credits`.
  final int availableCredits;

  final AngelSubscriptionStatus status;

  bool get isActive => status == AngelSubscriptionStatus.active;

  @override
  List<Object?> get props => [monthlyCredits, availableCredits, status];
}
