import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sponsor_a_dog/core/analytics/analytics_service.dart';
import 'package:sponsor_a_dog/core/auth/auth_repository.dart';
import 'package:sponsor_a_dog/core/constants/app_spacing.dart';
import 'package:sponsor_a_dog/core/theme/app_colors.dart';
import 'package:sponsor_a_dog/core/widgets/async_state_view.dart';
import 'package:sponsor_a_dog/features/dogs/domain/entities/dog.dart';
import 'package:sponsor_a_dog/features/dogs/domain/entities/promo_tile.dart';
import 'package:sponsor_a_dog/features/dogs/domain/repositories/dog_repository.dart';
import 'package:sponsor_a_dog/features/dogs/domain/usecases/get_dogs.dart';
import 'package:sponsor_a_dog/features/dogs/domain/usecases/get_promo_tiles.dart';
import 'package:sponsor_a_dog/features/dogs/presentation/bloc/dog_list_bloc.dart';
import 'package:sponsor_a_dog/features/dogs/presentation/pages/dog_detail_page.dart';
import 'package:sponsor_a_dog/features/dogs/presentation/widgets/explore_dog_card.dart';
import 'package:sponsor_a_dog/features/dogs/presentation/widgets/promo_tile_card.dart';

/// The "Explore" tab of the bottom nav — the sponsorable dog feed.
class ExplorePage extends StatelessWidget {
  const ExplorePage({this.onProfileTap, super.key});

  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    context.read<AnalyticsService>().logScreenView('explore');
    return BlocProvider(
      create: (context) => DogListBloc(
        getDogs: GetDogs(context.read<DogRepository>()),
        getPromoTiles: GetPromoTiles(context.read<DogRepository>()),
      )..add(const DogListFetchRequested()),
      child: _ExploreView(onProfileTap: onProfileTap),
    );
  }
}

class _ExploreView extends StatelessWidget {
  const _ExploreView({this.onProfileTap});

  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = context.read<AuthRepository>().displayName ?? 'there';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 72,
        title: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'hello $name,',
                    style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.bodyGray),
                  ),
                  Text('Pets waiting for you', style: theme.textTheme.headlineSmall),
                ],
              ),
            ),
            GestureDetector(
              onTap: onProfileTap,
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.neutralFill,
                  border: Border.all(color: AppColors.ink, width: 2),
                ),
                child: const Icon(LucideIcons.user, color: AppColors.ink, size: 20),
              ),
            ),
          ],
        ),
      ),
      body: BlocBuilder<DogListBloc, DogListState>(
        builder: (context, state) {
          return switch (state) {
            DogListInitial() || DogListLoading() =>
              const Center(child: CupertinoActivityIndicator()),
            DogListFailure(:final message) => ErrorStateView(
                message: message,
                onRetry: () =>
                    context.read<DogListBloc>().add(const DogListFetchRequested()),
              ),
            DogListLoaded(:final dogs, :final promoTiles) => RefreshIndicator(
                onRefresh: () async {
                  context.read<DogListBloc>().add(const DogListRefreshRequested());
                  await context
                      .read<DogListBloc>()
                      .stream
                      .firstWhere((s) => s is! DogListLoading);
                },
                child: _ExploreFeed(dogs: dogs, promoTiles: promoTiles),
              ),
          };
        },
      ),
    );
  }
}

class _ExploreFeed extends StatelessWidget {
  const _ExploreFeed({required this.dogs, required this.promoTiles});

  final List<Dog> dogs;
  final List<PromoTile> promoTiles;

  @override
  Widget build(BuildContext context) {
    final analytics = context.read<AnalyticsService>();

    // Splice promo tiles into the dog feed at their configured position.
    final items = <Object>[];
    for (var i = 0; i < dogs.length; i++) {
      items.add(dogs[i]);
      for (final tile in promoTiles) {
        if (tile.insertAfterIndex == i) items.add(tile);
      }
    }

    return ListView(
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
              Text('Sponsor a Special Pup', style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'These brave senior and special needs dogs are looking for '
                'long-term sponsors to help with their ongoing care, treats, '
                'and plenty of love.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.bodyGray),
              ),
            ],
          ),
        ),
        for (final item in items)
          switch (item) {
            Dog() => ExploreDogCard(
                dog: item,
                onTap: () {
                  analytics.logEvent(
                    'dog_card_tapped',
                    parameters: {'dog_id': item.id, 'dog_name': item.name},
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DogDetailPage(dog: item)),
                  );
                },
              ),
            PromoTile() => PromoTileCard(
                tile: item,
                onTap: () {
                  analytics.logEvent('promo_tile_tapped', parameters: {'tile_id': item.id});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Thank you for your support!')),
                  );
                },
              ),
            _ => const SizedBox.shrink(),
          },
      ],
    );
  }
}
