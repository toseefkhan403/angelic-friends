import 'package:brutalist_ui/brutalist_ui.dart' show NeoBox, NeoButton;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:sponsor_a_dog/core/constants/app_spacing.dart';
import 'package:sponsor_a_dog/core/purchases/purchases_service.dart';
import 'package:sponsor_a_dog/core/theme/app_colors.dart';
import 'package:sponsor_a_dog/features/angel/domain/repositories/angel_repository.dart';
import 'package:sponsor_a_dog/features/angel/presentation/bloc/sponsor_cta_bloc.dart';
import 'package:sponsor_a_dog/features/dogs/domain/entities/promo_tile.dart';
import 'package:sponsor_a_dog/features/dogs/presentation/widgets/feeding_pledge_sheet.dart';

/// Donation-upsell card spliced into the Explore feed, e.g. the "Daily
/// Feedings" tile — a photo background with the tile's copy overlaid, and a
/// CTA that reuses the same credits-or-paywall decision as a dog's "Sponsor"
/// button (see [SponsorCtaBloc]), just pledging into the general feeding
/// fund instead of onto one dog.
class PromoTileCard extends StatelessWidget {
  const PromoTileCard({required this.tile, this.onTap, super.key});

  final PromoTile tile;

  /// Fired when the CTA button is pressed, before the credits/paywall flow
  /// starts — e.g. for analytics.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: NeoBox(
        padding: EdgeInsets.zero,
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (tile.imageUrl != null)
                CachedNetworkImage(imageUrl: tile.imageUrl!, fit: BoxFit.cover)
              else
                Container(color: AppColors.mustard.withValues(alpha: 0.15)),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black87],
                    stops: [0.35, 1],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tile.title,
                        style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        tile.subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _FeedingCta(ctaLabel: tile.ctaLabel, onPressed: onTap),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedingCta extends StatelessWidget {
  const _FeedingCta({required this.ctaLabel, this.onPressed});

  final String ctaLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SponsorCtaBloc(
        angelRepository: context.read<AngelRepository>(),
        purchasesService: context.read<PurchasesService>(),
      ),
      child: _FeedingCtaView(ctaLabel: ctaLabel, onPressed: onPressed),
    );
  }
}

class _FeedingCtaView extends StatelessWidget {
  const _FeedingCtaView({required this.ctaLabel, this.onPressed});

  final String ctaLabel;
  final VoidCallback? onPressed;

  Future<void> _handleState(BuildContext context, SponsorCtaState state) async {
    final bloc = context.read<SponsorCtaBloc>();
    switch (state) {
      case SponsorCtaShowDonateSheet(:final availableCredits):
        await showFeedingPledgeSheet(context, availableCredits: availableCredits);
        bloc.add(const SponsorCtaReset());
      case SponsorCtaShowPaywall():
        var purchasedOrRestored = false;
        try {
          final result = await RevenueCatUI.presentPaywall();
          purchasedOrRestored =
              result == PaywallResult.purchased || result == PaywallResult.restored;
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Couldn't open the paywall: $e")),
            );
          }
        }
        bloc.add(SponsorCtaPaywallFinished(purchasedOrRestored: purchasedOrRestored));
      case SponsorCtaFailure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        bloc.add(const SponsorCtaReset());
      case SponsorCtaIdle():
      case SponsorCtaChecking():
      case SponsorCtaPolling():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SponsorCtaBloc, SponsorCtaState>(
      listener: _handleState,
      builder: (context, state) {
        final isBusy = state is SponsorCtaChecking || state is SponsorCtaPolling;
        return SizedBox(
          width: double.infinity,
          child: NeoButton(
            onPressed: isBusy
                ? null
                : () {
                    onPressed?.call();
                    context.read<SponsorCtaBloc>().add(const SponsorCtaPressed());
                  },
            child: Text(ctaLabel.toUpperCase()),
          ),
        );
      },
    );
  }
}
