import 'package:sponsor_a_dog/features/admin/domain/entities/admin_sponsorship_overview.dart';

class AdminSponsorshipOverviewModel {
  const AdminSponsorshipOverviewModel({
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

  factory AdminSponsorshipOverviewModel.fromJson(Map<String, dynamic> json) =>
      AdminSponsorshipOverviewModel(
        sponsorshipId: json['sponsorship_id'] as String,
        dogId: json['dog_id'] as String,
        dogName: json['dog_name'] as String,
        userId: json['user_id'] as String,
        angelName: json['angel_name'] as String,
        credits: json['credits'] as int,
        status: json['status'] as String,
        startedAt: DateTime.parse(json['started_at'] as String),
        lastMessageAt: json['last_message_at'] == null
            ? null
            : DateTime.parse(json['last_message_at'] as String),
        lastUserMessageAt: json['last_user_message_at'] == null
            ? null
            : DateTime.parse(json['last_user_message_at'] as String),
      );

  AdminSponsorshipOverview toEntity() => AdminSponsorshipOverview(
        sponsorshipId: sponsorshipId,
        dogId: dogId,
        dogName: dogName,
        userId: userId,
        angelName: angelName,
        credits: credits,
        status: status,
        startedAt: startedAt,
        lastMessageAt: lastMessageAt,
        lastUserMessageAt: lastUserMessageAt,
      );
}
