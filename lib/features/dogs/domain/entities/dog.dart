import 'package:equatable/equatable.dart';

class Dog extends Equatable {
  const Dog({
    required this.id,
    required this.name,
    required this.breed,
    required this.ageInMonths,
    required this.imageUrl,
    required this.story,
    required this.monthlyFundingGoal,
    this.fundedCredits = 0,
    this.careTag,
    this.personalityTags = const [],
    this.sex,
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

  /// This dog's monthly funding goal, in credits ($1 = 1 credit). Defaults
  /// to 30 for every dog unless overridden.
  final int monthlyFundingGoal;

  /// Live sum of credits currently pledged to this dog by all Angels
  /// (denormalized server-side, kept in sync by a Postgres trigger whenever
  /// `sponsorships.credits`/`status` changes). Drives the funding meter.
  final int fundedCredits;

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
        monthlyFundingGoal,
        fundedCredits,
      ];
}
