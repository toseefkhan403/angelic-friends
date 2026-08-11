import 'package:equatable/equatable.dart';

enum MessageSenderType { user, handler }

enum MessageMediaType { text, video }

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.senderType,
    required this.mediaType,
    required this.createdAt,
    this.text,
    this.mediaUrl,
    this.mediaThumbnailUrl,
    this.mediaDurationLabel,
  });

  final String id;
  final MessageSenderType senderType;
  final MessageMediaType mediaType;
  final String? text;
  final String? mediaUrl;
  final String? mediaThumbnailUrl;

  /// Display label for a video bubble's duration badge, e.g. "0:45".
  /// Free text rather than a computed Duration since it's just UI chrome.
  final String? mediaDurationLabel;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
        id,
        senderType,
        mediaType,
        text,
        mediaUrl,
        mediaThumbnailUrl,
        mediaDurationLabel,
        createdAt,
      ];
}
