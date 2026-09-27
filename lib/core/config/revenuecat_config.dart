/// RevenueCat "Angelic Friends" project (proj0f173a2f). Both platforms now
/// point at their real store apps' production keys, with the angel_10/20/50
/// products registered and attached to the same packages/entitlement as the
/// Test Store versions. Note: the iOS subscriptions haven't been submitted
/// to Apple for review yet (no screenshot/first-build submission done), so
/// only sandbox/TestFlight purchases will work until that's done.
/// These are safe to ship client-side (they're public keys, not secrets).
abstract final class RevenueCatConfig {
  static const String androidApiKey = 'goog_sdTcTKQiJElzOiRVlgsySOZpSkO';
  static const String iosApiKey = 'appl_JpNnntigVkVguiqmCErPDNaxPJP';
}
