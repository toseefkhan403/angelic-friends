import 'package:equatable/equatable.dart';

/// A marketing/donation-upsell card spliced into the Explore feed between
/// dog cards (e.g. "Large portions"). See docs/DATABASE_SCHEMA.md.
class PromoTile extends Equatable {
  const PromoTile({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.insertAfterIndex,
  });

  final String id;
  final String title;
  final String subtitle;
  final String ctaLabel;

  /// 0-based position in the dog list after which this tile is rendered.
  final int insertAfterIndex;

  @override
  List<Object?> get props => [id, title, subtitle, ctaLabel, insertAfterIndex];
}
