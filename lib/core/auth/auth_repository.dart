import 'package:dartz/dartz.dart';
import 'package:sponsor_a_dog/core/error/failures.dart';

abstract class AuthRepository {
  /// Whether there is a live Supabase auth session right now.
  bool get isSignedIn;

  /// The signed-in user's id, or null if signed out. Used to identify the
  /// user to RevenueCat (see `PurchasesService.logIn`).
  String? get currentUserId;

  /// Emits the current sign-in state whenever the underlying auth session
  /// changes (sign in, sign out, token refresh, etc.).
  Stream<bool> get authStateChanges;

  /// The signed-in user's display name, as stored in their auth metadata.
  /// Anonymous sign-in stores it under `display_name`; Google/Apple sign-in
  /// populate `full_name` (Apple only on the very first sign-in) instead —
  /// checked in that order.
  String? get displayName;

  /// True iff the signed-in user's auth `app_metadata` carries
  /// `is_admin: true`. `app_metadata` (not `user_metadata`) because it isn't
  /// client-writable — it's flipped on once via a manual SQL update, never
  /// through the app. Gates visibility of the "Admin" tile in Profile; RLS
  /// is the real enforcement either way.
  bool get isAdmin;

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
