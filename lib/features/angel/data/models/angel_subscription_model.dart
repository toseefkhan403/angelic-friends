import 'package:sponsor_a_dog/features/angel/domain/entities/angel_subscription.dart';

class AngelSubscriptionModel {
  const AngelSubscriptionModel({
    required this.monthlyCredits,
    required this.availableCredits,
    required this.status,
  });

  final int monthlyCredits;
  final int availableCredits;
  final AngelSubscriptionStatus status;

  factory AngelSubscriptionModel.fromJson(Map<String, dynamic> json) => AngelSubscriptionModel(
        monthlyCredits: (json['monthly_credits'] as num).toInt(),
        availableCredits: (json['available_credits'] as num).toInt(),
        status: _statusFromJson(json['status'] as String),
      );

  AngelSubscription toEntity() => AngelSubscription(
        monthlyCredits: monthlyCredits,
        availableCredits: availableCredits,
        status: status,
      );
}

AngelSubscriptionStatus _statusFromJson(String value) => switch (value) {
      'cancelled' => AngelSubscriptionStatus.cancelled,
      _ => AngelSubscriptionStatus.active,
    };
