import 'package:sponsor_a_dog/features/sponsors/domain/entities/chat_message.dart';

class ChatMessageModel {
  const ChatMessageModel({
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
  final String? mediaDurationLabel;
  final DateTime createdAt;

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) => ChatMessageModel(
        id: json['id'] as String,
        senderType: _senderTypeFromJson(json['sender_type'] as String),
        mediaType: _mediaTypeFromJson(json['media_type'] as String),
        text: json['text'] as String?,
        mediaUrl: json['media_url'] as String?,
        mediaThumbnailUrl: json['media_thumbnail_url'] as String?,
        mediaDurationLabel: json['media_duration_label'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  ChatMessage toEntity() => ChatMessage(
        id: id,
        senderType: senderType,
        mediaType: mediaType,
        text: text,
        mediaUrl: mediaUrl,
        mediaThumbnailUrl: mediaThumbnailUrl,
        mediaDurationLabel: mediaDurationLabel,
        createdAt: createdAt,
      );
}

MessageSenderType _senderTypeFromJson(String value) => switch (value) {
      'handler' => MessageSenderType.handler,
      _ => MessageSenderType.user,
    };

MessageMediaType _mediaTypeFromJson(String value) => switch (value) {
      'video' => MessageMediaType.video,
      _ => MessageMediaType.text,
    };
