import 'package:equatable/equatable.dart';

/// The rescue/shelter organization that lists a dog. See
/// docs/DATABASE_SCHEMA.md.
class Shelter extends Equatable {
  const Shelter({
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

  /// Static placeholder distance — there's no real geolocation feature yet,
  /// so this may be null.
  final double? distanceKm;

  /// Link to the shelter's location, e.g. a Google Maps URL. Set per-shelter
  /// in the database rather than derived client-side.
  final String? mapsUrl;

  @override
  List<Object?> get props => [id, name, location, logoUrl, distanceKm, mapsUrl];
}
