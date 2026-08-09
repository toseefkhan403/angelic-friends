import 'package:dartz/dartz.dart';
import 'package:sponsor_a_dog/core/error/failures.dart';

abstract class AuthRepository {
  /// Whether there is a live Supabase auth session right now.
  bool get isSignedIn;

  /// Emits the current sign-in state whenever the underlying auth session
  /// changes (sign in, sign out, token refresh, etc.).
  Stream<bool> get authStateChanges;

  /// The signed-in user's display name, as stored in their auth metadata.
  String? get displayName;

  Future<Either<Failure, void>> signInAnonymouslyWithName(String name);
  Future<Either<Failure, void>> signOut();
}
