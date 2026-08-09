import 'package:dartz/dartz.dart';
import 'package:sponsor_a_dog/core/auth/auth_repository.dart';
import 'package:sponsor_a_dog/core/error/failures.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthRepository implements AuthRepository {
  const SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  @override
  bool get isSignedIn => _client.auth.currentSession != null;

  @override
  Stream<bool> get authStateChanges =>
      _client.auth.onAuthStateChange.map((state) => state.session != null);

  @override
  String? get displayName => _client.auth.currentUser?.userMetadata?['display_name'] as String?;

  @override
  Future<Either<Failure, void>> signInAnonymouslyWithName(String name) async {
    try {
      await _client.auth.signInAnonymously(data: {'display_name': name});
      return const Right(null);
    } on AuthException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _client.auth.signOut();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
