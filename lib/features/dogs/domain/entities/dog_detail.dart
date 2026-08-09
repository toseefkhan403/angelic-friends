import 'package:equatable/equatable.dart';
import 'package:sponsor_a_dog/features/dogs/domain/entities/dog.dart';
import 'package:sponsor_a_dog/features/dogs/domain/entities/shelter.dart';
import 'package:sponsor_a_dog/features/dogs/domain/entities/sponsorship_impact.dart';

/// The full detail-page payload for a single dog: the dog itself plus its
/// photo gallery, listing shelter, and sponsorship impact line items.
class DogDetail extends Equatable {
  const DogDetail({
    required this.dog,
    required this.galleryImageUrls,
    required this.shelter,
    required this.impacts,
  });

  final Dog dog;
  final List<String> galleryImageUrls;

  /// Null when the dog has no `shelter_id` set.
  final Shelter? shelter;
  final List<SponsorshipImpact> impacts;

  @override
  List<Object?> get props => [dog, galleryImageUrls, shelter, impacts];
}
