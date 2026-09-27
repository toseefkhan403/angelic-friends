import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:sponsor_a_dog/core/auth/auth_repository.dart';
import 'package:sponsor_a_dog/core/config/social_auth_config.dart';
import 'package:sponsor_a_dog/core/error/failures.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthRepository implements AuthRepository {
  const SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  @override
  bool get isSignedIn => _client.auth.currentSession != null;

  @override
  String? get currentUserId => _client.auth.currentUser?.id;

  @override
  Stream<bool> get authStateChanges =>
      _client.auth.onAuthStateChange.map((state) => state.session != null);

  @override
  String? get displayName {
    final metadata = _client.auth.currentUser?.userMetadata;
    return metadata?['display_name'] as String? ?? metadata?['full_name'] as String?;
  }

  @override
  bool get isAdmin => _client.auth.currentUser?.appMetadata['is_admin'] == true;

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
  Future<Either<Failure, void>> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize(
        serverClientId: SocialAuthConfig.googleWebClientId,
        clientId: SocialAuthConfig.googleIosClientId,
      );

      if (!googleSignIn.supportsAuthenticate()) {
        return const Left(ServerFailure('Google sign-in is not supported on this device.'));
      }

      final googleUser = await googleSignIn.authenticate();
      final authorization =
          await googleUser.authorizationClient.authorizationForScopes(['email', 'profile']);
      final idToken = googleUser.authentication.idToken;

      if (idToken == null) {
        return const Left(ServerFailure('Google sign-in did not return an ID token.'));
      }

      await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: authorization?.accessToken,
      );
      return const Right(null);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return const Left(AuthCancelledFailure());
      return Left(ServerFailure(e.description ?? 'Google sign-in failed.'));
    } on AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signInWithApple() async {
    final isNativeApplePlatform =
        defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS;

    try {
      if (isNativeApplePlatform) {
        final rawNonce = _client.auth.generateRawNonce();
        final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

        final credential = await SignInWithApple.getAppleIDCredential(
          scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
          nonce: hashedNonce,
        );

        final idToken = credential.identityToken;
        if (idToken == null) {
          return const Left(ServerFailure('Apple sign-in did not return an ID token.'));
        }

        // Apple is supposed to echo the hashed nonce we sent back as the
        // id_token's `nonce` claim, but on some flows (e.g. a cached/
        // quick-reauth Apple ID grant) it omits the claim entirely even
        // though we requested one. Supabase's signInWithIdToken rejects the
        // call if exactly one of "nonce param" / "nonce claim" is present,
        // so only pass the raw nonce when the token actually carries one.
        await _client.auth.signInWithIdToken(
          provider: OAuthProvider.apple,
          idToken: idToken,
          nonce: _hasNonceClaim(idToken) ? rawNonce : null,
        );

        // Apple only ever sends the name on the very first sign-in for a
        // given app — capture it now or it's gone for good.
        if (credential.givenName != null || credential.familyName != null) {
          final fullName =
              [credential.givenName, credential.familyName].whereType<String>().join(' ');
          await _client.auth.updateUser(UserAttributes(data: {'full_name': fullName}));
        }
      } else {
        // No native Sign in with Apple on Android — fall back to Supabase's
        // browser-based OAuth redirect (see SocialAuthConfig.oAuthRedirectUrl).
        await _client.auth.signInWithOAuth(
          OAuthProvider.apple,
          redirectTo: SocialAuthConfig.oAuthRedirectUrl,
          authScreenLaunchMode: LaunchMode.externalApplication,
        );
      }
      return const Right(null);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) return const Left(AuthCancelledFailure());
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
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

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      await _client.rpc('delete_my_account');
      // The auth.users row is already gone server-side (which itself
      // revokes every session) — sign out locally too so the client's own
      // state and `_AppRoot`'s auth stream reflect it immediately rather
      // than waiting on a token refresh to fail.
      await _client.auth.signOut();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  bool _hasNonceClaim(String jwt) {
    try {
      final payload = jwt.split('.')[1];
      final normalized = base64Url.normalize(payload);
      final claims = jsonDecode(utf8.decode(base64Url.decode(normalized))) as Map<String, dynamic>;
      return claims.containsKey('nonce');
    } catch (_) {
      return false;
    }
  }
}
