/// RevenueCat "Angelic Friends" project (proj0f173a2f), currently wired to
/// its auto-provisioned Test Store app — lets purchases be tested end to
/// end without any App Store Connect / Play Console setup. Both platform
/// keys point at the same Test Store key for now; once real App Store
/// Connect / Play Console apps are added in the RevenueCat dashboard, swap
/// each in for its own `appl_`/`goog_` public key.
/// These are safe to ship client-side (they're public keys, not secrets).
abstract final class RevenueCatConfig {
  static const String androidApiKey = 'test_VdpfNJaWxWxVgtKXaQUEeIyRbpH';
  static const String iosApiKey = 'test_VdpfNJaWxWxVgtKXaQUEeIyRbpH';
}
