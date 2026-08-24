import 'package:sponsor_a_dog/features/dogs/data/models/dog_model.dart';
import 'package:sponsor_a_dog/features/sponsors/domain/entities/sponsorship.dart';

class SponsorshipModel {
  const SponsorshipModel({
    required this.id,
    required this.dog,
    required this.credits,
    required this.startedAt,
  });

  final String id;
  final DogModel dog;
  final int credits;
  final DateTime startedAt;

  factory SponsorshipModel.fromJson(Map<String, dynamic> json) => SponsorshipModel(
        id: json['id'] as String,
        dog: DogModel.fromJson(json['dogs'] as Map<String, dynamic>),
        credits: (json['credits'] as num).toInt(),
        startedAt: DateTime.parse(json['started_at'] as String),
      );

  Sponsorship toEntity() => Sponsorship(
        id: id,
        dog: dog.toEntity(),
        credits: credits,
        startedAt: startedAt,
      );
}
