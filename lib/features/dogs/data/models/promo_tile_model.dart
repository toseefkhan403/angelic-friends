import 'package:sponsor_a_dog/features/dogs/domain/entities/promo_tile.dart';

class PromoTileModel {
  const PromoTileModel({
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
  final int insertAfterIndex;

  factory PromoTileModel.fromJson(Map<String, dynamic> json) => PromoTileModel(
        id: json['id'] as String,
        title: json['title'] as String,
        subtitle: json['subtitle'] as String,
        ctaLabel: json['cta_label'] as String,
        insertAfterIndex: (json['insert_after_index'] as num).toInt(),
      );

  PromoTile toEntity() => PromoTile(
        id: id,
        title: title,
        subtitle: subtitle,
        ctaLabel: ctaLabel,
        insertAfterIndex: insertAfterIndex,
      );
}
