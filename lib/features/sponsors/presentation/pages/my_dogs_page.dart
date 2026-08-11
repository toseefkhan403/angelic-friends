import 'package:brutalist_ui/brutalist_ui.dart' show NeoButton;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sponsor_a_dog/core/analytics/analytics_service.dart';
import 'package:sponsor_a_dog/core/constants/app_spacing.dart';
import 'package:sponsor_a_dog/core/theme/app_colors.dart';
import 'package:sponsor_a_dog/core/widgets/async_state_view.dart';
import 'package:sponsor_a_dog/features/sponsors/domain/entities/sponsorship.dart';
import 'package:sponsor_a_dog/features/sponsors/domain/repositories/sponsorship_repository.dart';
import 'package:sponsor_a_dog/features/sponsors/domain/usecases/get_my_sponsorships.dart';
import 'package:sponsor_a_dog/features/sponsors/presentation/bloc/sponsors_bloc.dart';
import 'package:sponsor_a_dog/features/sponsors/presentation/pages/chat_detail_page.dart';
import 'package:sponsor_a_dog/features/sponsors/presentation/widgets/next_update_banner.dart';
import 'package:sponsor_a_dog/features/sponsors/presentation/widgets/sponsor_another_pal_card.dart';
import 'package:sponsor_a_dog/features/sponsors/presentation/widgets/sponsored_dog_card.dart';

/// The "My Dogs" tab — "My Pups": the dogs the user actively sponsors, each
/// leading to that dog's chat. Chat only exists here because it only ever
/// appears for a dog with an active sponsorship (see docs/PRODUCT_SPEC.md
/// §4.8 — chat unlocks with payment, not before).
class MyDogsPage extends StatelessWidget {
  const MyDogsPage({this.onExplore, super.key});

  final VoidCallback? onExplore;

  @override
  Widget build(BuildContext context) {
    context.read<AnalyticsService>().logScreenView('my_dogs');
    return BlocProvider(
      create: (context) => SponsorsBloc(
        getMySponsorships: GetMySponsorships(context.read<SponsorshipRepository>()),
      )..add(const SponsorsFetchRequested()),
      child: _MyDogsView(onExplore: onExplore),
    );
  }
}

class _MyDogsView extends StatelessWidget {
  const _MyDogsView({this.onExplore});

  final VoidCallback? onExplore;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<SponsorsBloc, SponsorsState>(
          builder: (context, state) {
            return switch (state) {
              SponsorsInitial() || SponsorsLoading() =>
                const Center(child: CupertinoActivityIndicator()),
              SponsorsFailure(:final message) => ErrorStateView(
                  message: message,
                  onRetry: () =>
                      context.read<SponsorsBloc>().add(const SponsorsFetchRequested()),
                ),
              SponsorsLoaded(:final sponsorships) => _MyDogsContent(
                  sponsorships: sponsorships,
                  onExplore: onExplore,
                ),
            };
          },
        ),
      ),
    );
  }
}

class _MyDogsContent extends StatelessWidget {
  const _MyDogsContent({required this.sponsorships, this.onExplore});

  final List<Sponsorship> sponsorships;
  final VoidCallback? onExplore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (sponsorships.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.heart, size: 48, color: AppColors.bodyGray),
              const SizedBox(height: AppSpacing.md),
              Text(
                "You haven't sponsored a dog yet",
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Meet the dogs waiting for an angel and start your first sponsorship.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.bodyGray),
              ),
              const SizedBox(height: AppSpacing.lg),
              NeoButton(onPressed: onExplore, child: const Text('Meet the dogs')),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<SponsorsBloc>().add(const SponsorsRefreshRequested());
        await context.read<SponsorsBloc>().stream.firstWhere((s) => s is! SponsorsLoading);
      },
      child: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('My Pups', style: theme.textTheme.displaySmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Stay connected with the wonderful dogs you sponsor.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.bodyGray),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: const NextUpdateBanner(),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final sponsorship in sponsorships)
            SponsoredDogCard(
              sponsorship: sponsorship,
              onOpenChat: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ChatDetailPage(sponsorship: sponsorship)),
              ),
              onSendTreat: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon')),
              ),
            ),
          SponsorAnotherPalCard(onTap: onExplore ?? () {}),
        ],
      ),
    );
  }
}
