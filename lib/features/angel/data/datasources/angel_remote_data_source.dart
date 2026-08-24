import 'package:sponsor_a_dog/core/error/exceptions.dart';
import 'package:sponsor_a_dog/features/angel/data/models/angel_subscription_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AngelRemoteDataSource {
  Future<AngelSubscriptionModel?> getMySubscription();
  Future<void> pledgeCredits({required String dogId, required int credits});
}

class AngelRemoteDataSourceImpl implements AngelRemoteDataSource {
  const AngelRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  String get _userId {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw const ServerException('You need to be signed in for that.');
    return userId;
  }

  @override
  Future<AngelSubscriptionModel?> getMySubscription() async {
    try {
      final row = await _client
          .from('angel_subscribers')
          .select()
          .eq('user_id', _userId)
          .maybeSingle();
      return row == null ? null : AngelSubscriptionModel.fromJson(row);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<void> pledgeCredits({required String dogId, required int credits}) async {
    try {
      await _client.rpc('pledge_credits', params: {'p_dog_id': dogId, 'p_credits': credits});
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }
}
