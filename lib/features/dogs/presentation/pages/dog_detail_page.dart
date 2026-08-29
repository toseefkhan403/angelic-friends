import 'package:brutalist_ui/brutalist_ui.dart' show NeoBox, NeoButton, NeoButtonSize, NeoIconButton;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sponsor_a_dog/core/constants/app_spacing.dart';
import 'package:sponsor_a_dog/core/purchases/purchases_service.dart';
import 'package:sponsor_a_dog/core/theme/app_colors.dart';
import 'package:sponsor_a_dog/core/utils/url_launcher_util.dart';
import 'package:sponsor_a_dog/core/widgets/async_state_view.dart';
import 'package:sponsor_a_dog/core/widgets/auto_play_video.dart';
import 'package:sponsor_a_dog/core/widgets/page_dots_indicator.dart';
import 'package:sponsor_a_dog/features/angel/domain/repositories/angel_repository.dart';
import 'package:sponsor_a_dog/features/angel/presentation/bloc/sponsor_cta_bloc.dart';
import 'package:sponsor_a_dog/features/dogs/domain/entities/dog.dart';
import 'package:sponsor_a_dog/features/dogs/domain/entities/dog_detail.dart';
import 'package:sponsor_a_dog/features/dogs/domain/entities/dog_media.dart';
import 'package:sponsor_a_dog/features/dogs/domain/entities/shelter.dart';
import 'package:sponsor_a_dog/features/dogs/domain/repositories/dog_repository.dart';
import 'package:sponsor_a_dog/features/dogs/domain/usecases/get_dog_detail.dart';
import 'package:sponsor_a_dog/features/dogs/presentation/bloc/dog_detail_bloc.dart';
import 'package:sponsor_a_dog/features/dogs/presentation/widgets/donate_credits_sheet.dart';
import 'package:sponsor_a_dog/features/dogs/presentation/widgets/funding_meter.dart';
import 'package:sponsor_a_dog/features/sponsors/presentation/widgets/sponsorship_celebration_dialog.dart';

/// The dog detail screen, reached by tapping a card in the Explore feed.
///
/// Takes the tapped [Dog] so the shell (back button) can render instantly,
/// but always re-fetches the full detail via [DogDetailBloc] rather than
/// trusting the passed-in [Dog], so this page also works if reached some
/// other way later (e.g. a deep link).
class DogDetailPage extends StatelessWidget {
  const DogDetailPage({required this.dog, super.key});

  final Dog dog;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DogDetailBloc(
        getDogDetail: GetDogDetail(context.read<DogRepository>()),
      )..add(DogDetailFetchRequested(dog.id)),
      child: _DogDetailView(fallbackDog: dog),
    );
  }
}

class _DogDetailView extends StatelessWidget {
  const _DogDetailView({required this.fallbackDog});

  final Dog fallbackDog;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ground,
      body: BlocBuilder<DogDetailBloc, DogDetailState>(
        builder: (context, state) {
          return switch (state) {
            DogDetailInitial() || DogDetailLoading() => Stack(
                children: [
                  const Center(child: CupertinoActivityIndicator()),
                  Positioned(
                    top: AppSpacing.md,
                    left: AppSpacing.md,
                    child: SafeArea(bottom: false, child: _BackButton()),
                  ),
                ],
              ),
            DogDetailFailure(:final message) => Stack(
                children: [
                  SafeArea(
                    child: ErrorStateView(
                      message: message,
                      onRetry: () => context
                          .read<DogDetailBloc>()
                          .add(DogDetailFetchRequested(fallbackDog.id)),
                    ),
                  ),
                  Positioned(
                    top: AppSpacing.md,
                    left: AppSpacing.md,
                    child: SafeArea(bottom: false, child: _BackButton()),
                  ),
                ],
              ),
            DogDetailLoaded(:final detail) => _DogDetailContent(detail: detail),
          };
        },
      ),
    );
  }
}

class _DogDetailContent extends StatelessWidget {
  const _DogDetailContent({required this.detail});

  final DogDetail detail;

  @override
  Widget build(BuildContext context) {
    final media = detail.media.isNotEmpty
        ? detail.media
        : [DogMedia(mediaType: DogMediaType.image, url: detail.dog.imageUrl)];

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PhotoCarousel(media: media),
              // Pull the panel up so it overlaps the bottom of the photo, per the
              // reference layout.
              Transform.translate(
                offset: const Offset(0, -AppSpacing.lg),
                child: _DetailPanel(detail: detail),
              ),
            ],
          ),
        ),
        Positioned(
          top: AppSpacing.md,
          left: AppSpacing.md,
          child: SafeArea(bottom: false, child: _BackButton()),
        ),
      ],
    );
  }
}

class _PhotoCarousel extends StatefulWidget {
  const _PhotoCarousel({required this.media});

  final List<DogMedia> media;

  @override
  State<_PhotoCarousel> createState() => _PhotoCarouselState();
}

class _PhotoCarouselState extends State<_PhotoCarousel> {
  final _controller = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 420,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.media.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              final item = widget.media[index];
              return switch (item.mediaType) {
                DogMediaType.image => CachedNetworkImage(
                    imageUrl: item.url,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.neutralFill,
                      child: const Center(child: CupertinoActivityIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.neutralFill,
                      child: const Icon(LucideIcons.image, size: 48, color: AppColors.bodyGray),
                    ),
                  ),
                DogMediaType.video => AutoPlayVideo(
                    videoUrl: item.url,
                    thumbnailUrl: item.thumbnailUrl,
                    isActive: index == _currentIndex,
                  ),
              };
            },
          ),
          if (widget.media.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: AppSpacing.md,
              child: Center(
                child: PageDotsIndicator(
                  count: widget.media.length,
                  currentIndex: _currentIndex,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return NeoIconButton(
      onPressed: () => Navigator.pop(context),
      semanticLabel: 'Back',
      size: NeoButtonSize.small,
      icon: const Icon(LucideIcons.chevronLeft),
    );
  }
}

class _DetailPanel extends StatelessWidget {
  const _DetailPanel({required this.detail});

  final DogDetail detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dog = detail.dog;
    final years = (dog.ageInMonths / 12).round();

    return NeoBox(
      color: AppColors.ground,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        dog.name,
                        style: theme.textTheme.titleLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (dog.sex != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        dog.sex == 'female' ? '♀' : '♂',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: dog.sex == 'female'
                              ? const Color(0xFFE0559C)
                              : const Color(0xFF3D7FE0),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              NeoIconButton(
                onPressed: () => _shareDog(dog),
                semanticLabel: 'Share',
                size: NeoButtonSize.small,
                icon: const Icon(LucideIcons.share2),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '${dog.breed} · $years ${years == 1 ? 'year' : 'years'}',
            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.bodyGray),
          ),
          const SizedBox(height: AppSpacing.md),
          _BioSection(story: dog.story),
          if (detail.shelter != null) ...[
            const SizedBox(height: AppSpacing.lg),
            const Divider(),
            const SizedBox(height: AppSpacing.md),
            _ShelterRow(shelter: detail.shelter!),
          ],
          if (detail.impacts.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            const Divider(),
            const SizedBox(height: AppSpacing.md),
            Text('Sponsorship Impact', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            for (final impact in detail.impacts)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NeoBox(
                      color: AppColors.mustard.withValues(alpha: 0.15),
                      shadowOffset: Offset.zero,
                      constraints: const BoxConstraints.tightFor(width: 36, height: 36),
                      alignment: Alignment.center,
                      child: Icon(_iconFor(impact.icon), size: 18, color: AppColors.ink),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: Text(impact.description, style: theme.textTheme.bodyMedium),
                      ),
                    ),
                  ],
                ),
              ),
          ],
          const SizedBox(height: AppSpacing.lg),
          FundingMeter(fundedCredits: dog.fundedCredits, goalCredits: dog.monthlyFundingGoal),
          const SizedBox(height: AppSpacing.md),
          _SponsorCta(dog: dog),
        ],
      ),
    );
  }
}

/// The "Sponsor {dog}" call to action. Always the same button — the branch
/// happens on tap, not in the button's label/state; see [SponsorCtaBloc] for
/// the decision logic (has credits -> donate sheet; no subscription/balance
/// -> RevenueCat's own paywall, no custom fallback picker is ever built for
/// this, then poll briefly for the new balance and flow into the sheet).
class _SponsorCta extends StatelessWidget {
  const _SponsorCta({required this.dog});

  final Dog dog;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SponsorCtaBloc(
        angelRepository: context.read<AngelRepository>(),
        purchasesService: context.read<PurchasesService>(),
      ),
      child: _SponsorCtaView(dog: dog),
    );
  }
}

class _SponsorCtaView extends StatelessWidget {
  const _SponsorCtaView({required this.dog});

  final Dog dog;

  Future<void> _handleState(BuildContext context, SponsorCtaState state) async {
    final bloc = context.read<SponsorCtaBloc>();
    switch (state) {
      case SponsorCtaShowDonateSheet(:final availableCredits):
        final sponsorship =
            await showDonateCreditsSheet(context, dog: dog, availableCredits: availableCredits);
        bloc.add(const SponsorCtaReset());
        if (sponsorship != null && context.mounted) {
          // Refresh this page's own funding meter — a pledge just changed
          // dog.fundedCredits server-side.
          context.read<DogDetailBloc>().add(DogDetailFetchRequested(dog.id));
          await showSponsorshipCelebrationDialog(context, sponsorship: sponsorship);
        }
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
            onPressed:
                isBusy ? null : () => context.read<SponsorCtaBloc>().add(const SponsorCtaPressed()),
            child: Text('Sponsor ${dog.name}'),
          ),
        );
      },
    );
  }
}

class _BioSection extends StatefulWidget {
  const _BioSection({required this.story});

  final String story;

  @override
  State<_BioSection> createState() => _BioSectionState();
}

class _BioSectionState extends State<_BioSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.story,
          style: theme.textTheme.bodyMedium,
          maxLines: _expanded ? null : 3,
          overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.xs),
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Text(
            _expanded ? 'SEE LESS' : 'SEE MORE',
            style: theme.textTheme.labelMedium,
          ),
        ),
      ],
    );
  }
}

class _ShelterRow extends StatelessWidget {
  const _ShelterRow({required this.shelter});

  final Shelter shelter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locationLine = shelter.distanceKm != null
        ? '${shelter.location} · ${shelter.distanceKm!.toStringAsFixed(1)} km from you'
        : shelter.location;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: shelter.instagramUrl != null ? () => openUrl(shelter.instagramUrl!) : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: AppColors.neutralFill,
              border: Border.all(color: AppColors.ink, width: 2),
            ),
            child: shelter.logoUrl != null
                ? CachedNetworkImage(
                    imageUrl: shelter.logoUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) =>
                        const Icon(LucideIcons.home, size: 20, color: AppColors.bodyGray),
                  )
                : const Icon(LucideIcons.home, size: 20, color: AppColors.bodyGray),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(shelter.name, style: theme.textTheme.titleSmall, overflow: TextOverflow.ellipsis),
                Text(
                  locationLine,
                  style: theme.textTheme.bodySmall?.copyWith(color: AppColors.bodyGray),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (shelter.mapsUrl != null)
            NeoButton(
              size: NeoButtonSize.small,
              onPressed: () => openUrl(shelter.mapsUrl!),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(LucideIcons.mapPin, size: 16),
                  SizedBox(width: AppSpacing.xs),
                  Text('Locate'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Maps the string keys `sponsorship_impacts.icon` stores in the database
/// (not Dart identifiers) to the lucide icon they represent.
IconData _iconFor(String key) {
  return switch (key) {
    'plusCircle' => LucideIcons.plusCircle,
    'coffee' => LucideIcons.coffee,
    'moon' => LucideIcons.moon,
    'heart' => LucideIcons.heart,
    'zap' => LucideIcons.zap,
    'shield' => LucideIcons.shield,
    _ => LucideIcons.checkCircle,
  };
}

Future<void> _shareDog(Dog dog) {
  return SharePlus.instance.share(
    ShareParams(
      subject: 'Meet ${dog.name}',
      text: 'Meet ${dog.name}, a ${dog.breed} in need of some love.\n\n'
          '${dog.story}\n\n'
          "Become ${dog.name}'s Angelic Friend and help fund their care.",
    ),
  );
}
