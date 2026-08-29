import 'package:sponsor_a_dog/features/angel/domain/entities/feeding_pledge.dart';

class FeedingPledgeModel {
  const FeedingPledgeModel({
    required this.id,
    required this.credits,
    required this.createdAt,
  });

  final String id;
  final int credits;
  final DateTime createdAt;

  factory FeedingPledgeModel.fromJson(Map<String, dynamic> json) => FeedingPledgeModel(
        id: json['id'] as String,
        credits: (json['credits'] as num).toInt(),
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  FeedingPledge toEntity() => FeedingPledge(id: id, credits: credits, createdAt: createdAt);
}
