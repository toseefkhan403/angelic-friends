import 'package:equatable/equatable.dart';

/// One row of `admin_sponsorship_overview()` — an admin's view of a single
/// sponsor's ("Angel") thread with a dog, used to list and prioritize
/// threads that need a reply.
class AdminSponsorshipOverview extends Equatable {
  const AdminSponsorshipOverview({
    required this.sponsorshipId,
    required this.dogId,
    required this.dogName,
    required this.userId,
    required this.angelName,
    required this.credits,
    required this.status,
    required this.startedAt,
    this.lastMessageAt,
    this.lastUserMessageAt,
  });

  final String sponsorshipId;
  final String dogId;
  final String dogName;
  final String userId;
  final String angelName;
  final int credits;
  final String status;
  final DateTime startedAt;
  final DateTime? lastMessageAt;
  final DateTime? lastUserMessageAt;

  /// True when the sponsor's last message hasn't been answered yet — the
  /// thread's most recent message is from them, not the handler.
  bool get needsReply =>
      lastUserMessageAt != null &&
      lastMessageAt != null &&
      lastUserMessageAt!.isAtSameMomentAs(lastMessageAt!);

  @override
  List<Object?> get props => [
        sponsorshipId,
        dogId,
        dogName,
        userId,
        angelName,
        credits,
        status,
        startedAt,
        lastMessageAt,
        lastUserMessageAt,
      ];
}
