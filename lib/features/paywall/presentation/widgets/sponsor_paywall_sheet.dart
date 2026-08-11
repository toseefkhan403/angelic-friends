import 'package:brutalist_ui/brutalist_ui.dart' show NeoBox, NeoButton;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sponsor_a_dog/core/constants/app_spacing.dart';
import 'package:sponsor_a_dog/core/purchases/purchases_service.dart';
import 'package:sponsor_a_dog/core/theme/app_colors.dart';
import 'package:sponsor_a_dog/features/dogs/domain/entities/dog.dart';
import 'package:sponsor_a_dog/features/sponsors/domain/entities/sponsorship.dart';
import 'package:sponsor_a_dog/features/sponsors/domain/repositories/sponsorship_repository.dart';

/// Bottom sheet offering the Silver/Gold sponsorship tiers for [dog].
///
/// Product ids and pricing are per-dog (see `dogs.silver_product_id` /
/// `dogs.gold_product_id` in Supabase). A purchase only ever grants a
/// sponsorship once the `revenuecat-webhook` Edge Function has verified it
/// server-side and written the row — this sheet has no way to write
/// `sponsorships` itself, so after a successful purchase it polls briefly
/// for the row to appear rather than creating it.
Future<void> showSponsorPaywallSheet(BuildContext context, Dog dog) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _SponsorPaywallSheet(dog: dog),
  );
}

class _SponsorPaywallSheet extends StatefulWidget {
  const _SponsorPaywallSheet({required this.dog});

  final Dog dog;

  @override
  State<_SponsorPaywallSheet> createState() => _SponsorPaywallSheetState();
}

class _SponsorPaywallSheetState extends State<_SponsorPaywallSheet> {
  bool _isProcessing = false;

  Future<void> _choose(_Tier tier) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final purchasesService = context.read<PurchasesService>();
    final sponsorshipRepository = context.read<SponsorshipRepository>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final offeringsResult = await purchasesService.getOfferings();

    if (!mounted) return;

    await offeringsResult.fold(
      (failure) async {
        messenger.showSnackBar(SnackBar(content: Text(failure.message)));
      },
      (offerings) async {
        final packages = offerings.current?.availablePackages ??
            offerings.all.values.expand((offering) => offering.availablePackages).toList();

        Package? match;
        for (final package in packages) {
          if (package.storeProduct.identifier == tier.productId) {
            match = package;
            break;
          }
        }

        if (match == null) {
          messenger.showSnackBar(
            const SnackBar(content: Text("This sponsorship isn't available right now.")),
          );
          return;
        }

        final purchaseResult = await purchasesService.purchasePackage(match);
        if (!mounted) return;

        await purchaseResult.fold(
          (failure) async => messenger.showSnackBar(SnackBar(content: Text(failure.message))),
          (_) => _confirmSponsorship(
            sponsorshipRepository: sponsorshipRepository,
            tier: tier,
            messenger: messenger,
            navigator: navigator,
          ),
        );
      },
    );

    if (mounted) setState(() => _isProcessing = false);
  }

  /// The RevenueCat webhook usually lands within a couple of seconds, but
  /// isn't instant — poll briefly for the sponsorship it creates rather than
  /// erroring just because it hasn't shown up yet.
  static const _confirmPollInterval = Duration(milliseconds: 1500);
  static const _confirmTimeout = Duration(seconds: 15);

  Future<void> _confirmSponsorship({
    required SponsorshipRepository sponsorshipRepository,
    required _Tier tier,
    required ScaffoldMessengerState messenger,
    required NavigatorState navigator,
  }) async {
    final deadline = DateTime.now().add(_confirmTimeout);

    while (DateTime.now().isBefore(deadline)) {
      if (!mounted) return;
      final result = await sponsorshipRepository.getMySponsorships();
      final found = result.fold(
        (_) => false,
        (sponsorships) => sponsorships.any(
          (s) => s.dog.id == widget.dog.id && s.tier == tier.tier,
        ),
      );
      if (found) {
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(content: Text("You're now sponsoring ${widget.dog.name}!")),
        );
        navigator.pop();
        return;
      }
      await Future.delayed(_confirmPollInterval);
    }

    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          'Your payment went through — ${widget.dog.name}\'s sponsorship will appear shortly.',
        ),
      ),
    );
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final dog = widget.dog;
    final tiers = [
      _Tier(
        name: 'Silver',
        tier: SponsorshipTier.silver,
        price: dog.silverPrice,
        description: "Monthly updates and chat with ${dog.name}'s handler.",
        productId: dog.silverProductId,
      ),
      _Tier(
        name: 'Gold',
        tier: SponsorshipTier.gold,
        price: dog.goldPrice,
        description: "Weekly video updates and chat with ${dog.name}'s handler.",
        productId: dog.goldProductId,
      ),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: NeoBox(
          color: AppColors.ground,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sponsor ${dog.name}', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.md),
              for (final tier in tiers) ...[
                _TierCard(
                  tier: tier,
                  enabled: !_isProcessing,
                  onChoose: () => _choose(tier),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Tier {
  const _Tier({
    required this.name,
    required this.tier,
    required this.price,
    required this.description,
    required this.productId,
  });

  final String name;
  final SponsorshipTier tier;
  final double price;
  final String description;
  final String? productId;
}

class _TierCard extends StatelessWidget {
  const _TierCard({required this.tier, required this.enabled, required this.onChoose});

  final _Tier tier;
  final bool enabled;
  final VoidCallback onChoose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return NeoBox(
      color: AppColors.neutralFill,
      shadowOffset: Offset.zero,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tier.name, style: theme.textTheme.titleLarge),
                Text(
                  '\$${tier.price.toStringAsFixed(0)}/mo',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  tier.description,
                  style: theme.textTheme.bodySmall?.copyWith(color: AppColors.bodyGray),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          NeoButton(
            onPressed: enabled ? onChoose : null,
            child: const Text('Choose'),
          ),
        ],
      ),
    );
  }
}
