import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sponsor_a_dog/core/purchases/purchases_service.dart';
import 'package:sponsor_a_dog/features/angel/domain/repositories/angel_repository.dart';

part 'sponsor_cta_event.dart';
part 'sponsor_cta_state.dart';

/// Drives a dog detail page's "Sponsor" button: decides, on tap, whether the
/// user already has Angel credits to pledge ([SponsorCtaShowDonateSheet]) or
/// needs to subscribe first ([SponsorCtaShowPaywall]), then polls for the
/// new balance after a successful purchase.
///
/// Presenting the native RevenueCat paywall UI and the donate-credits bottom
/// sheet both require a [BuildContext], so this bloc only decides *when* to
/// show them — the widget's `BlocListener` does the actual presenting and
/// reports the outcome back via [SponsorCtaPaywallFinished]. The "show X"
/// states are one-shot: after the widget acts on one, it dispatches
/// [SponsorCtaReset] so the same state can fire again on a later tap.
class SponsorCtaBloc extends Bloc<SponsorCtaEvent, SponsorCtaState> {
  SponsorCtaBloc({
    required AngelRepository angelRepository,
    required PurchasesService purchasesService,
  })  : _angelRepository = angelRepository,
        _purchasesService = purchasesService,
        super(const SponsorCtaIdle()) {
    on<SponsorCtaPressed>(_onPressed);
    on<SponsorCtaPaywallFinished>(_onPaywallFinished);
    on<SponsorCtaReset>((event, emit) => emit(const SponsorCtaIdle()));
  }

  final AngelRepository _angelRepository;
  final PurchasesService _purchasesService;

  /// The RevenueCat webhook usually lands within a couple of seconds, but
  /// isn't instant — poll briefly for the credits it grants rather than
  /// erroring just because they haven't shown up yet.
  static const _pollInterval = Duration(milliseconds: 1500);
  static const _pollTimeout = Duration(seconds: 15);

  Future<void> _onPressed(SponsorCtaPressed event, Emitter<SponsorCtaState> emit) async {
    emit(const SponsorCtaChecking());
    final result = await _angelRepository.getMySubscription();
    result.fold(
      (failure) => emit(SponsorCtaFailure(failure.message)),
      (subscription) {
        if (subscription != null && subscription.isActive && subscription.availableCredits > 0) {
          emit(SponsorCtaShowDonateSheet(subscription.availableCredits));
        } else if (!_purchasesService.isAvailable) {
          emit(const SponsorCtaFailure('Purchases are not available on this platform.'));
        } else {
          emit(const SponsorCtaShowPaywall());
        }
      },
    );
  }

  Future<void> _onPaywallFinished(
    SponsorCtaPaywallFinished event,
    Emitter<SponsorCtaState> emit,
  ) async {
    if (!event.purchasedOrRestored) {
      emit(const SponsorCtaIdle());
      return;
    }

    emit(const SponsorCtaPolling());
    final deadline = DateTime.now().add(_pollTimeout);
    while (DateTime.now().isBefore(deadline)) {
      final result = await _angelRepository.getMySubscription();
      final subscription = result.fold((_) => null, (s) => s);
      if (subscription != null && subscription.isActive && subscription.availableCredits > 0) {
        emit(SponsorCtaShowDonateSheet(subscription.availableCredits));
        return;
      }
      await Future.delayed(_pollInterval);
    }

    emit(const SponsorCtaFailure(
      'Your payment went through — your credits will appear shortly.',
    ));
  }
}
