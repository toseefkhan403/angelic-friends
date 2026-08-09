import 'package:sponsor_a_dog/features/dogs/domain/entities/shelter.dart';

class ShelterModel {
  const ShelterModel({
    required this.id,
    required this.name,
    required this.location,
    this.logoUrl,
    this.distanceKm,
    this.mapsUrl,
  });

  final String id;
  final String name;
  final String location;
  final String? logoUrl;
  final double? distanceKm;
  final String? mapsUrl;

  factory ShelterModel.fromJson(Map<String, dynamic> json) => ShelterModel(
        id: json['id'] as String,
        name: json['name'] as String,
        location: json['location'] as String,
        logoUrl: json['logo_url'] as String?,
        distanceKm: (json['distance_km'] as num?)?.toDouble(),
        mapsUrl: json['maps_url'] as String?,
      );

  Shelter toEntity() => Shelter(
        id: id,
        name: name,
        location: location,
        logoUrl: logoUrl,
        distanceKm: distanceKm,
        mapsUrl: mapsUrl,
      );
}
