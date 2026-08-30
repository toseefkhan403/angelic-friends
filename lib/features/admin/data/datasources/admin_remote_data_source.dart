import 'dart:io';

import 'package:sponsor_a_dog/core/error/exceptions.dart';
import 'package:sponsor_a_dog/features/admin/data/models/admin_dog_update_status_model.dart';
import 'package:sponsor_a_dog/features/admin/data/models/admin_sponsorship_overview_model.dart';
import 'package:sponsor_a_dog/features/sponsors/data/models/chat_message_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AdminRemoteDataSource {
  Future<List<AdminSponsorshipOverviewModel>> getAngelOverviews();
  Future<List<ChatMessageModel>> getMessages(String sponsorshipId);
  Future<ChatMessageModel> sendHandlerReply({required String sponsorshipId, required String text});
  Future<List<AdminDogUpdateStatusModel>> getDogUpdateStatuses();
  Future<String> uploadWeeklyUpdateVideo({required String dogId, required File videoFile});
  Future<int> sendWeeklyUpdate({required String dogId, required String mediaUrl, String? caption});
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  const AdminRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<List<AdminSponsorshipOverviewModel>> getAngelOverviews() async {
    try {
      final rows = await _client.rpc('admin_sponsorship_overview') as List<dynamic>;
      final overviews = rows
          .map((row) => AdminSponsorshipOverviewModel.fromJson(row as Map<String, dynamic>))
          .toList();
      // Threads needing a reply first, then most recently active.
      overviews.sort((a, b) {
        if (a.toEntity().needsReply != b.toEntity().needsReply) {
          return a.toEntity().needsReply ? -1 : 1;
        }
        final aTime = a.lastMessageAt ?? a.startedAt;
        final bTime = b.lastMessageAt ?? b.startedAt;
        return bTime.compareTo(aTime);
      });
      return overviews;
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<List<ChatMessageModel>> getMessages(String sponsorshipId) async {
    try {
      final rows = await _client
          .from('messages')
          .select()
          .eq('sponsorship_id', sponsorshipId)
          .order('created_at', ascending: true);
      return rows.map(ChatMessageModel.fromJson).toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<ChatMessageModel> sendHandlerReply({
    required String sponsorshipId,
    required String text,
  }) async {
    try {
      final row = await _client
          .from('messages')
          .insert({
            'sponsorship_id': sponsorshipId,
            'sender_type': 'handler',
            'media_type': 'text',
            'text': text,
          })
          .select()
          .single();
      return ChatMessageModel.fromJson(row);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<List<AdminDogUpdateStatusModel>> getDogUpdateStatuses() async {
    try {
      final rows = await _client.rpc('admin_dog_update_status') as List<dynamic>;
      final statuses = rows
          .map((row) => AdminDogUpdateStatusModel.fromJson(row as Map<String, dynamic>))
          .toList();
      // Never-sent first, then oldest last-sent first.
      statuses.sort((a, b) {
        if (a.lastWeeklyUpdateSentAt == null) return b.lastWeeklyUpdateSentAt == null ? 0 : -1;
        if (b.lastWeeklyUpdateSentAt == null) return 1;
        return a.lastWeeklyUpdateSentAt!.compareTo(b.lastWeeklyUpdateSentAt!);
      });
      return statuses;
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<String> uploadWeeklyUpdateVideo({required String dogId, required File videoFile}) async {
    try {
      final ext = videoFile.path.split('.').last;
      final path = 'dog-updates/$dogId/${DateTime.now().millisecondsSinceEpoch}.$ext';
      await _client.storage.from('dog-media').upload(path, videoFile);
      return _client.storage.from('dog-media').getPublicUrl(path);
    } on StorageException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<int> sendWeeklyUpdate({
    required String dogId,
    required String mediaUrl,
    String? caption,
  }) async {
    try {
      final result = await _client.rpc('send_weekly_update', params: {
        'p_dog_id': dogId,
        'p_media_url': mediaUrl,
        'p_media_thumbnail_url': null,
        'p_caption': caption,
      });
      return result as int;
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }
}
