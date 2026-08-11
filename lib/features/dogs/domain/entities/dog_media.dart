import 'package:equatable/equatable.dart';

enum DogMediaType { image, video }

class DogMedia extends Equatable {
  const DogMedia({
    required this.mediaType,
    required this.url,
    this.thumbnailUrl,
    this.sortOrder = 0,
    this.caption,
  });

  final DogMediaType mediaType;
  final String url;
  final String? thumbnailUrl;
  final int sortOrder;

  /// Short handler-style update line, e.g. "Pip took ten extra minutes on
  /// his walk today." Set only on the media rows featured in onboarding's
  /// update marquee — most rows leave this null.
  final String? caption;

  @override
  List<Object?> get props => [mediaType, url, thumbnailUrl, sortOrder, caption];
}
