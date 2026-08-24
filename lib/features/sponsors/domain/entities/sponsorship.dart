import 'package:equatable/equatable.dart';
import 'package:sponsor_a_dog/features/dogs/domain/entities/dog.dart';

/// An active sponsorship the current user holds on [dog]. Its existence (with
/// `credits > 0`) is what unlocks that dog's chat — see docs/PRODUCT_SPEC.md
/// §9. [credits] is the lifetime total this user has pledged to this dog —
/// permanent, only ever increases, via the `pledge_credits` RPC.
class Sponsorship extends Equatable {
  const Sponsorship({
    required this.id,
    required this.dog,
    required this.credits,
    required this.startedAt,
  });

  final String id;
  final Dog dog;
  final int credits;
  final DateTime startedAt;

  /// Pledging more than $10/mo to this dog unlocks weekly video updates
  /// (instead of the base monthly cadence).
  bool get hasWeeklyUpdates => credits > 10;

  @override
  List<Object?> get props => [id, dog, credits, startedAt];
}
