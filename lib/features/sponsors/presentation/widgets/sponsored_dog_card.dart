import 'package:brutalist_ui/brutalist_ui.dart' show NeoBadge, NeoBox, NeoButton, NeoIconButton, NeoButtonSize;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sponsor_a_dog/core/constants/app_spacing.dart';
import 'package:sponsor_a_dog/core/theme/app_colors.dart';
import 'package:sponsor_a_dog/features/sponsors/domain/entities/chat_message.dart';
import 'package:sponsor_a_dog/features/sponsors/domain/entities/sponsorship.dart';
import 'package:sponsor_a_dog/features/sponsors/domain/repositories/sponsorship_repository.dart';

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// A sponsored dog's card in "My Pups": photo, personality badge, name,
/// latest update preview, Send Treat + chat entry point.
class SponsoredDogCard extends StatelessWidget {
  const SponsoredDogCard({
    required this.sponsorship,
    required this.onOpenChat,
    required this.onSendTreat,
    super.key,
  });

  final Sponsorship sponsorship;
  final VoidCallback onOpenChat;
  final VoidCallback onSendTreat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dog = sponsorship.dog;
    final trait = dog.personalityTags.isNotEmpty ? dog.personalityTags.first : null;
    final sinceLabel = _months[sponsorship.startedAt.month - 1];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: GestureDetector(
        onTap: onOpenChat,
        child: NeoBox(
          shadowOffset: Offset.zero,
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 10,
                    child: CachedNetworkImage(
                      imageUrl: dog.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.neutralFill,
                        child: const Center(child: CupertinoActivityIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.neutralFill,
                        child: const Icon(LucideIcons.image, size: 40, color: AppColors.bodyGray),
                      ),
                    ),
                  ),
                  if (trait != null)
                    Positioned(
                      top: AppSpacing.sm,
                      right: AppSpacing.sm,
                      child: NeoBadge(child: Text(trait)),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(dog.name, style: theme.textTheme.titleLarge)),
                        const Icon(LucideIcons.heart, size: 14, color: AppColors.bodyGray),
                        const SizedBox(width: 4),
                        Text(
                          'Sponsored since $sinceLabel',
                          style: theme.textTheme.bodySmall?.copyWith(color: AppColors.bodyGray),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _LatestUpdatePreview(sponsorshipId: sponsorship.id),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: NeoButton(
                            onPressed: onSendTreat,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(LucideIcons.bone, size: 16),
                                SizedBox(width: 6),
                                Text('Send Treat'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        NeoIconButton(
                          onPressed: onOpenChat,
                          semanticLabel: 'Chat about ${dog.name}',
                          size: NeoButtonSize.small,
                          icon: const Icon(LucideIcons.mail),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LatestUpdatePreview extends StatelessWidget {
  const _LatestUpdatePreview({required this.sponsorshipId});

  final String sponsorshipId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder(
      future: context.read<SponsorshipRepository>().getMessages(sponsorshipId),
      builder: (context, snapshot) {
        var preview = 'Say hello to start the conversation!';
        final result = snapshot.data;
        if (result != null) {
          result.fold((_) {}, (messages) {
            if (messages.isNotEmpty) {
              final last = messages.last;
              preview = last.mediaType == MessageMediaType.video
                  ? '📹 ${last.text ?? "New video update"}'
                  : (last.text ?? preview);
            }
          });
        }

        return NeoBox(
          color: AppColors.mustard.withValues(alpha: 0.12),
          shadowOffset: Offset.zero,
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.sparkles, size: 14, color: AppColors.ink),
                  const SizedBox(width: 4),
                  Text('Latest Update', style: theme.textTheme.labelSmall),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                preview,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        );
      },
    );
  }
}
