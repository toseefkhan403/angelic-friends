import 'package:equatable/equatable.dart';
import 'package:sponsor_a_dog/features/dogs/domain/entities/dog_media.dart';

/// A single captioned [DogMedia] row paired with its dog's name/care tag,
/// used to populate onboarding's "real updates" marquee and letter slide.
class DogUpdateHighlight extends Equatable {
  const DogUpdateHighlight({
    required this.dogName,
    required this.media,
    this.careTag,
  });

  final String dogName;
  final String? careTag;
  final DogMedia media;

  @override
  List<Object?> get props => [dogName, careTag, media];
}
