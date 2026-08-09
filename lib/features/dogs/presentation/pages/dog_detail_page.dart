import 'package:brutalist_ui/brutalist_ui.dart' show NeoBox, NeoButton, NeoButtonSize, NeoIconButton;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sponsor_a_dog/core/constants/app_spacing.dart';
import 'package:sponsor_a_dog/core/theme/app_colors.dart';
import 'package:sponsor_a_dog/core/utils/url_launcher_util.dart';
import 'package:sponsor_a_dog/core/widgets/async_state_view.dart';
import 'package:sponsor_a_dog/core/widgets/page_dots_indicator.dart';
import 'package:sponsor_a_dog/features/dogs/domain/entities/dog.dart';
import 'package:sponsor_a_dog/features/dogs/domain/entities/dog_detail.dart';
import 'package:sponsor_a_dog/features/dogs/domain/entities/shelter.dart';
import 'package:sponsor_a_dog/features/dogs/domain/repositories/dog_repository.dart';
import 'package:sponsor_a_dog/features/dogs/domain/usecases/get_dog_detail.dart';
import 'package:sponsor_a_dog/features/dogs/presentation/bloc/dog_detail_bloc.dart';

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
                  const Center(child: CircularProgressIndicator()),
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
    final imageUrls =
        detail.galleryImageUrls.isNotEmpty ? detail.galleryImageUrls : [detail.dog.imageUrl];

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PhotoCarousel(imageUrls: imageUrls),
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
  const _PhotoCarousel({required this.imageUrls});

  final List<String> imageUrls;

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
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) => Image.network(
              widget.imageUrls[index],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppColors.neutralFill,
                child: const Icon(LucideIcons.image, size: 48, color: AppColors.bodyGray),
              ),
            ),
          ),
          if (widget.imageUrls.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: AppSpacing.md,
              child: Center(
                child: PageDotsIndicator(
                  count: widget.imageUrls.length,
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
                onPressed: () => _showComingSoon(context),
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
          SizedBox(
            width: double.infinity,
            child: NeoButton(
              onPressed: () => _showComingSoon(context),
              child: Text('Sponsor ${dog.name}'),
            ),
          ),
        ],
      ),
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

    return Row(
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
              ? Image.network(
                  shelter.logoUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
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

void _showComingSoon(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coming soon')));
}
