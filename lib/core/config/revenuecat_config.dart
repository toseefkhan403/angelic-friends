/// RevenueCat "Angelic Friends" project (proj0f173a2f). Android points at
/// the real Play Store app's production key — note this app has no
/// registered Play Store products or service-account credentials yet, so
/// purchases will fail until that's finished (see revenuecat_config
/// follow-up work). iOS still points at the Test Store key until an App
/// Store Connect app exists in RevenueCat.
/// These are safe to ship client-side (they're public keys, not secrets).
abstract final class RevenueCatConfig {
  static const String androidApiKey = 'goog_sdTcTKQiJElzOiRVlgsySOZpSkO';
  static const String iosApiKey = 'test_VdpfNJaWxWxVgtKXaQUEeIyRbpH';
}
