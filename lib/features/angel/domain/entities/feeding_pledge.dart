import 'package:equatable/equatable.dart';

/// A permanent credit pledge the current user made to the general feeding
/// fund (not tied to any one dog) — see `pledge_credits_to_feeding`.
class FeedingPledge extends Equatable {
  const FeedingPledge({
    required this.id,
    required this.credits,
    required this.createdAt,
  });

  final String id;
  final int credits;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, credits, createdAt];
}
