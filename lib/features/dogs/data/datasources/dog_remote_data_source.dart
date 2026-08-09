import 'package:sponsor_a_dog/core/error/exceptions.dart';
import 'package:sponsor_a_dog/features/dogs/data/models/dog_model.dart';
import 'package:sponsor_a_dog/features/dogs/data/models/promo_tile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class DogRemoteDataSource {
  Future<List<DogModel>> getDogs();
  Future<List<PromoTileModel>> getPromoTiles();

  /// Returns the raw joined row for a single dog (dog columns plus nested
  /// `shelters` and `sponsorship_impacts`), so the repository can assemble a
  /// DogDetail entity. Unlike the other methods here, this doesn't return a
  /// model because the shape it returns isn't itself a single table's row —
  /// it's a PostgREST embed of three tables the repository splits back apart.
  Future<Map<String, dynamic>> getDogDetail(String dogId);
}

class DogRemoteDataSourceImpl implements DogRemoteDataSource {
  const DogRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<List<DogModel>> getDogs() async {
    try {
      final rows = await _client.from('dogs').select().order('sort_order');
      return rows.map(DogModel.fromJson).toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<List<PromoTileModel>> getPromoTiles() async {
    try {
      final rows = await _client
          .from('promo_tiles')
          .select()
          .eq('is_active', true)
          .order('insert_after_index');
      return rows.map(PromoTileModel.fromJson).toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<Map<String, dynamic>> getDogDetail(String dogId) async {
    try {
      final row = await _client
          .from('dogs')
          .select('*, shelters(*), sponsorship_impacts(*)')
          .eq('id', dogId)
          .single();
      return row;
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }
}
