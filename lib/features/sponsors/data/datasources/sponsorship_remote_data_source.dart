import 'dart:async';

import 'package:sponsor_a_dog/core/error/exceptions.dart';
import 'package:sponsor_a_dog/features/sponsors/data/models/chat_message_model.dart';
import 'package:sponsor_a_dog/features/sponsors/data/models/sponsorship_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SponsorshipRemoteDataSource {
  Future<List<SponsorshipModel>> getMySponsorships();
  Future<List<ChatMessageModel>> getMessages(String sponsorshipId);
  Future<ChatMessageModel> sendMessage({required String sponsorshipId, required String text});

  /// Emits every new message inserted for [sponsorshipId] via Supabase
  /// Realtime, for as long as the returned stream has a listener. RLS on
  /// `messages` (enforced by Realtime using the connected client's JWT)
  /// already restricts this to sponsorships the current user owns; the
  /// `sponsorship_id` filter here is purely to keep one chat screen from
  /// receiving every other sponsorship's inserts too.
  Stream<ChatMessageModel> watchNewMessages(String sponsorshipId);
}

class SponsorshipRemoteDataSourceImpl implements SponsorshipRemoteDataSource {
  const SponsorshipRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  String get _userId {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw const ServerException('You need to be signed in for that.');
    return userId;
  }

  @override
  Future<List<SponsorshipModel>> getMySponsorships() async {
    try {
      final rows = await _client
          .from('sponsorships')
          .select('*, dogs(*)')
          .eq('user_id', _userId)
          .eq('status', 'active')
          .order('started_at', ascending: true);
      return rows.map(SponsorshipModel.fromJson).toList();
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
  Future<ChatMessageModel> sendMessage({
    required String sponsorshipId,
    required String text,
  }) async {
    try {
      final row = await _client
          .from('messages')
          .insert({
            'sponsorship_id': sponsorshipId,
            'sender_type': 'user',
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
  Stream<ChatMessageModel> watchNewMessages(String sponsorshipId) {
    late final RealtimeChannel channel;
    late final StreamController<ChatMessageModel> controller;

    controller = StreamController<ChatMessageModel>(
      onCancel: () => _client.removeChannel(channel),
    );

    channel = _client
        .channel('messages:sponsorship_id=eq.$sponsorshipId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'sponsorship_id',
            value: sponsorshipId,
          ),
          callback: (payload) {
            if (!controller.isClosed) {
              controller.add(ChatMessageModel.fromJson(payload.newRecord));
            }
          },
        )
        .subscribe();

    return controller.stream;
  }
}
