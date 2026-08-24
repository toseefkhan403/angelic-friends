import 'package:sponsor_a_dog/features/dogs/domain/entities/dog.dart';

class DogModel {
  const DogModel({
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
  final String? careTag;
  final List<String> personalityTags;
  final String? sex;
  final int monthlyFundingGoal;
  final int fundedCredits;

  factory DogModel.fromJson(Map<String, dynamic> json) => DogModel(
        id: json['id'] as String,
        name: json['name'] as String,
        breed: json['breed'] as String,
        ageInMonths: (json['age_months'] as num).toInt(),
        imageUrl: json['image_url'] as String,
        story: json['story'] as String,
        careTag: json['care_tag'] as String?,
        personalityTags: (json['personality_tags'] as List<dynamic>?)
                ?.map((tag) => tag as String)
                .toList() ??
            const [],
        sex: json['sex'] as String?,
        monthlyFundingGoal: (json['monthly_funding_goal'] as num).toInt(),
        fundedCredits: (json['funded_credits'] as num?)?.toInt() ?? 0,
      );

  Dog toEntity() => Dog(
        id: id,
        name: name,
        breed: breed,
        ageInMonths: ageInMonths,
        imageUrl: imageUrl,
        story: story,
        careTag: careTag,
        personalityTags: personalityTags,
        sex: sex,
        monthlyFundingGoal: monthlyFundingGoal,
        fundedCredits: fundedCredits,
      );
}
