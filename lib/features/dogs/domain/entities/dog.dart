import 'package:equatable/equatable.dart';

class Dog extends Equatable {
  const Dog({
    required this.id,
    required this.name,
    required this.breed,
    required this.ageInMonths,
    required this.imageUrl,
    required this.story,
    required this.silverPrice,
    required this.goldPrice,
    this.careTag,
    this.personalityTags = const [],
    this.sex,
    this.silverProductId,
    this.goldProductId,
  });

  final String id;
  final String name;
  final String breed;
  final int ageInMonths;
  final String imageUrl;
  final String story;

  /// The status badge overlaid on the hero image, e.g. "Senior Care",
  /// "Wheels Needed". Free text, editorial rather than a fixed taxonomy.
  final String? careTag;

  /// Short personality chips, e.g. "Gentle Giant", "Loves Naps".
  final List<String> personalityTags;

  /// 'male' or 'female', when known. Not every dog has one set.
  final String? sex;

  /// Monthly price, in the store's local currency units, for the Silver
  /// sponsorship tier for this dog.
  final double silverPrice;

  /// Monthly price, in the store's local currency units, for the Gold
  /// sponsorship tier for this dog.
  final double goldPrice;

  /// The store (RevenueCat/App Store/Play Store) product id backing the
  /// Silver tier, e.g. `sponsor_<dog_id>_silver_monthly`. Null until the
  /// store product has been created for this dog.
  final String? silverProductId;

  /// The store product id backing the Gold tier. Null until the store
  /// product has been created for this dog.
  final String? goldProductId;

  @override
  List<Object?> get props => [
        id,
        name,
        breed,
        ageInMonths,
        imageUrl,
        story,
        careTag,
        personalityTags,
        sex,
        silverPrice,
        goldPrice,
        silverProductId,
        goldProductId,
      ];
}
