import 'package:sponsor_a_dog/features/admin/domain/entities/admin_dog_update_status.dart';

class AdminDogUpdateStatusModel {
  const AdminDogUpdateStatusModel({
    required this.dogId,
    required this.dogName,
    required this.eligibleSponsorCount,
    this.lastWeeklyUpdateSentAt,
  });

  final String dogId;
  final String dogName;
  final int eligibleSponsorCount;
  final DateTime? lastWeeklyUpdateSentAt;

  factory AdminDogUpdateStatusModel.fromJson(Map<String, dynamic> json) =>
      AdminDogUpdateStatusModel(
        dogId: json['dog_id'] as String,
        dogName: json['dog_name'] as String,
        eligibleSponsorCount: json['eligible_sponsor_count'] as int,
        lastWeeklyUpdateSentAt: json['last_weekly_update_sent_at'] == null
            ? null
            : DateTime.parse(json['last_weekly_update_sent_at'] as String),
      );

  AdminDogUpdateStatus toEntity() => AdminDogUpdateStatus(
        dogId: dogId,
        dogName: dogName,
        eligibleSponsorCount: eligibleSponsorCount,
        lastWeeklyUpdateSentAt: lastWeeklyUpdateSentAt,
      );
}
