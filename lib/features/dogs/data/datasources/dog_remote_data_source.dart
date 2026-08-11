import 'package:sponsor_a_dog/core/error/exceptions.dart';
import 'package:sponsor_a_dog/features/dogs/data/models/dog_model.dart';
import 'package:sponsor_a_dog/features/dogs/data/models/promo_tile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class DogRemoteDataSource {
  Future<List<DogModel>> getDogs();
  Future<List<PromoTileModel>> getPromoTiles();

  /// Returns the raw joined row for a single dog (dog columns plus nested
  /// `shelters`, `sponsorship_impacts`, and `dog_media`), so the repository
  /// can assemble a DogDetail entity. Unlike the other methods here, this
  /// doesn't return a model because the shape it returns isn't itself a
  /// single table's row — it's a PostgREST embed of four tables the
  /// repository splits back apart.
  Future<Map<String, dynamic>> getDogDetail(String dogId);

  /// Raw `dog_media` rows with a non-null `caption`, each joined with its
  /// dog's `name`/`care_tag`, for the repository to assemble into
  /// `DogUpdateHighlight`s.
  Future<List<Map<String, dynamic>>> getFeaturedMedia();
}

class DogRemoteDataSourceImpl implements DogRemoteDataSource {
  const DogRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<List<DogModel>> getDogs() async {
    try {
      final rows = await _client.from('dogs').select().order('sort_order', ascending: true);
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
          .order('insert_after_index', ascending: true);
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
          .select('*, shelters(*), sponsorship_impacts(*), dog_media(*)')
          .eq('id', dogId)
          .single();
      return row;
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getFeaturedMedia() async {
    try {
      final rows = await _client
          .from('dog_media')
          .select('*, dogs(name, care_tag)')
          .not('caption', 'is', null)
          .order('sort_order', ascending: true);
      return List<Map<String, dynamic>>.from(rows);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }
}
