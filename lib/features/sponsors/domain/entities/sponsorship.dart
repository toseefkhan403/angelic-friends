import 'package:equatable/equatable.dart';
import 'package:sponsor_a_dog/features/dogs/domain/entities/dog.dart';

enum SponsorshipTier { silver, gold }

/// An active sponsorship the current user holds on [dog]. Its existence is
/// what unlocks that dog's chat — see docs/PRODUCT_SPEC.md §9.
class Sponsorship extends Equatable {
  const Sponsorship({
    required this.id,
    required this.dog,
    required this.tier,
    required this.startedAt,
  });

  final String id;
  final Dog dog;
  final SponsorshipTier tier;
  final DateTime startedAt;

  @override
  List<Object?> get props => [id, dog, tier, startedAt];
}
