/// Google/Apple sign-in configuration. Client IDs are not secrets (they're
/// shipped in every app binary), but each one only works once it's:
///   1. Created in Google Cloud Console / Apple Developer, and
///   2. Registered as an OAuth provider (with the matching secret) in the
///      Supabase dashboard under Authentication → Providers.
/// See docs/PRODUCT_SPEC.md or the PR description for the exact setup
/// checklist. Until real values are filled in below, both sign-in buttons
/// will fail with a clear error rather than crash.
abstract final class SocialAuthConfig {
  /// Google Cloud Console → APIs & Services → Credentials → OAuth client ID
  /// of type "Web application". Used as `serverClientId` for
  /// `google_sign_in` on every platform (this is what makes the ID token's
  /// audience match what Supabase's Google provider expects) — NOT the
  /// Android or iOS client ID.
  static const String googleWebClientId =
      '761879030744-pv0eerrsovmdr07mnfqviv6grq33ffpp.apps.googleusercontent.com';

  /// Google Cloud Console OAuth client ID of type "iOS". Only used on
  /// iOS/macOS; required by `google_sign_in` there even though the web
  /// client id is what actually gets sent to Supabase.
  static const String googleIosClientId = 'TODO-REPLACE-WITH-GOOGLE-IOS-CLIENT-ID';

  /// Apple's "Sign in with Apple" only has a real native flow on iOS/macOS.
  /// On Android there's no equivalent, so `signInWithApple` falls back to
  /// Supabase's browser-based OAuth flow, which redirects back into the app
  /// via this custom scheme — must match the `android:scheme`/`android:host`
  /// pair added to AndroidManifest.xml's intent-filter, and must also be
  /// added to Supabase's Auth → URL Configuration → Redirect URLs.
  static const String oAuthRedirectUrl = 'com.sponsoradog.sponsor_a_dog://login-callback';
}
