part of 'sponsor_cta_bloc.dart';

sealed class SponsorCtaState extends Equatable {
  const SponsorCtaState();

  @override
  List<Object?> get props => [];
}

/// Resting state: button enabled, nothing in flight.
class SponsorCtaIdle extends SponsorCtaState {
  const SponsorCtaIdle();
}

/// Checking the user's current Angel subscription before deciding what to
/// show. Button disabled.
class SponsorCtaChecking extends SponsorCtaState {
  const SponsorCtaChecking();
}

/// One-shot: the widget should open the donate-credits sheet with
/// [availableCredits], then dispatch [SponsorCtaReset].
class SponsorCtaShowDonateSheet extends SponsorCtaState {
  const SponsorCtaShowDonateSheet(this.availableCredits);

  final int availableCredits;

  @override
  List<Object?> get props => [availableCredits];
}

/// One-shot: the widget should call `RevenueCatUI.presentPaywall()`, then
/// dispatch [SponsorCtaPaywallFinished] with the outcome.
class SponsorCtaShowPaywall extends SponsorCtaState {
  const SponsorCtaShowPaywall();
}

/// Waiting for the RevenueCat webhook to grant credits after a purchase.
/// Button disabled.
class SponsorCtaPolling extends SponsorCtaState {
  const SponsorCtaPolling();
}

/// One-shot: the widget should show [message] (e.g. in a SnackBar), then
/// dispatch [SponsorCtaReset].
class SponsorCtaFailure extends SponsorCtaState {
  const SponsorCtaFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
