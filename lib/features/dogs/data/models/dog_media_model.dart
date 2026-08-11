import 'package:sponsor_a_dog/features/dogs/domain/entities/dog_media.dart';

class DogMediaModel {
  const DogMediaModel({
    required this.mediaType,
    required this.url,
    this.thumbnailUrl,
    required this.sortOrder,
    this.caption,
  });

  final DogMediaType mediaType;
  final String url;
  final String? thumbnailUrl;
  final int sortOrder;
  final String? caption;

  factory DogMediaModel.fromJson(Map<String, dynamic> json) => DogMediaModel(
        mediaType: _mediaTypeFromJson(json['media_type'] as String),
        url: json['url'] as String,
        thumbnailUrl: json['thumbnail_url'] as String?,
        sortOrder: (json['sort_order'] as num).toInt(),
        caption: json['caption'] as String?,
      );

  DogMedia toEntity() => DogMedia(
        mediaType: mediaType,
        url: url,
        thumbnailUrl: thumbnailUrl,
        sortOrder: sortOrder,
        caption: caption,
      );
}

DogMediaType _mediaTypeFromJson(String value) => switch (value) {
      'video' => DogMediaType.video,
      _ => DogMediaType.image,
    };
