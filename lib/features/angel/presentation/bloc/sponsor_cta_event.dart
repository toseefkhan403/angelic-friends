part of 'sponsor_cta_bloc.dart';

sealed class SponsorCtaEvent {
  const SponsorCtaEvent();
}

class SponsorCtaPressed extends SponsorCtaEvent {
  const SponsorCtaPressed();
}

/// Reported by the widget after it presented RevenueCat's native paywall.
class SponsorCtaPaywallFinished extends SponsorCtaEvent {
  const SponsorCtaPaywallFinished({required this.purchasedOrRestored});

  final bool purchasedOrRestored;
}

/// Returns the bloc to [SponsorCtaIdle] after a one-shot state (show
/// paywall/sheet, or a failure message) has been handled by the widget, so
/// the same state can fire again on a later tap.
class SponsorCtaReset extends SponsorCtaEvent {
  const SponsorCtaReset();
}
