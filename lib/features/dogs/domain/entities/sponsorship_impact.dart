import 'package:equatable/equatable.dart';

/// A single line item describing what a sponsorship funds for a dog, e.g.
/// "Provides monthly joint supplements and senior wellness checks."
/// See docs/DATABASE_SCHEMA.md.
class SponsorshipImpact extends Equatable {
  const SponsorshipImpact({required this.icon, required this.description});

  /// A string key (e.g. 'plusCircle', 'coffee') mapped to an icon by the
  /// presentation layer — not a Dart identifier.
  final String icon;
  final String description;

  @override
  List<Object?> get props => [icon, description];
}
