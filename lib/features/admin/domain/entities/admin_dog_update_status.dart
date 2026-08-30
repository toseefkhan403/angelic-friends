import 'package:equatable/equatable.dart';

/// One row of `admin_dog_update_status()` — how overdue a dog is for its
/// next weekly video broadcast.
class AdminDogUpdateStatus extends Equatable {
  const AdminDogUpdateStatus({
    required this.dogId,
    required this.dogName,
    required this.eligibleSponsorCount,
    this.lastWeeklyUpdateSentAt,
  });

  final String dogId;
  final String dogName;

  /// Count of this dog's active sponsorships with `credits > 10` — the
  /// existing "unlocks weekly video updates" threshold, see
  /// `Sponsorship.hasWeeklyUpdates`.
  final int eligibleSponsorCount;
  final DateTime? lastWeeklyUpdateSentAt;

  @override
  List<Object?> get props => [dogId, dogName, eligibleSponsorCount, lastWeeklyUpdateSentAt];
}
