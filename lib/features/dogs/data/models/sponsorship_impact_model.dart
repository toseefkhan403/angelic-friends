import 'package:sponsor_a_dog/features/dogs/domain/entities/sponsorship_impact.dart';

class SponsorshipImpactModel {
  const SponsorshipImpactModel({
    required this.icon,
    required this.description,
    required this.sortOrder,
  });

  final String icon;
  final String description;

  /// Query-ordering concern only — not carried onto [SponsorshipImpact].
  final int sortOrder;

  factory SponsorshipImpactModel.fromJson(Map<String, dynamic> json) => SponsorshipImpactModel(
        icon: json['icon'] as String,
        description: json['description'] as String,
        sortOrder: (json['sort_order'] as num).toInt(),
      );

  SponsorshipImpact toEntity() => SponsorshipImpact(icon: icon, description: description);
}
