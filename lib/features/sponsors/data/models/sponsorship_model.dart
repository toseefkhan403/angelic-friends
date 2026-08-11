import 'package:sponsor_a_dog/features/dogs/data/models/dog_model.dart';
import 'package:sponsor_a_dog/features/sponsors/domain/entities/sponsorship.dart';

class SponsorshipModel {
  const SponsorshipModel({
    required this.id,
    required this.dog,
    required this.tier,
    required this.startedAt,
  });

  final String id;
  final DogModel dog;
  final SponsorshipTier tier;
  final DateTime startedAt;

  factory SponsorshipModel.fromJson(Map<String, dynamic> json) => SponsorshipModel(
        id: json['id'] as String,
        dog: DogModel.fromJson(json['dogs'] as Map<String, dynamic>),
        tier: _tierFromJson(json['tier'] as String),
        startedAt: DateTime.parse(json['started_at'] as String),
      );

  Sponsorship toEntity() => Sponsorship(
        id: id,
        dog: dog.toEntity(),
        tier: tier,
        startedAt: startedAt,
      );
}

SponsorshipTier _tierFromJson(String value) => switch (value) {
      'gold' => SponsorshipTier.gold,
      _ => SponsorshipTier.silver,
    };

String tierToJson(SponsorshipTier tier) => switch (tier) {
      SponsorshipTier.silver => 'silver',
      SponsorshipTier.gold => 'gold',
    };
