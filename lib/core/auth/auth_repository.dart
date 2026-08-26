import 'package:dartz/dartz.dart';
import 'package:sponsor_a_dog/core/error/failures.dart';

abstract class AuthRepository {
  /// Whether there is a live Supabase auth session right now.
  bool get isSignedIn;

  /// Emits the current sign-in state whenever the underlying auth session
  /// changes (sign in, sign out, token refresh, etc.).
  Stream<bool> get authStateChanges;

  /// The signed-in user's display name, as stored in their auth metadata.
  /// Anonymous sign-in stores it under `display_name`; Google/Apple sign-in
  /// populate `full_name` (Apple only on the very first sign-in) instead —
  /// checked in that order.
  String? get displayName;

  Future<Either<Failure, void>> signInAnonymouslyWithName(String name);

  /// Native Google sign-in on every platform, via `google_sign_in` +
  /// `supabase.auth.signInWithIdToken`. See `SocialAuthConfig` for the
  /// required Google Cloud Console setup.
  Future<Either<Failure, void>> signInWithGoogle();

  /// Native "Sign in with Apple" on iOS/macOS; falls back to Supabase's
  /// browser-based OAuth redirect on Android, where there's no native
  /// equivalent. See `SocialAuthConfig` for the required Apple
  /// Developer/Supabase setup.
  Future<Either<Failure, void>> signInWithApple();

  Future<Either<Failure, void>> signOut();
}
