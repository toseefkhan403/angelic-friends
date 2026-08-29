import 'package:brutalist_ui/brutalist_ui.dart' show NeoBox;
import 'package:dartz/dartz.dart' show Either, Left, Right;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sponsor_a_dog/core/constants/app_spacing.dart';
import 'package:sponsor_a_dog/core/error/failures.dart';
import 'package:sponsor_a_dog/core/theme/app_colors.dart';
import 'package:sponsor_a_dog/core/widgets/async_state_view.dart';
import 'package:sponsor_a_dog/features/angel/domain/entities/feeding_pledge.dart';
import 'package:sponsor_a_dog/features/angel/domain/repositories/angel_repository.dart';
import 'package:sponsor_a_dog/features/sponsors/domain/entities/sponsorship.dart';
import 'package:sponsor_a_dog/features/sponsors/domain/repositories/sponsorship_repository.dart';

/// A single line in the credits-pledged history — either a lifetime pledge
/// to a specific dog ([dogName] set) or to the general feeding fund (null).
class _DonationEntry {
  const _DonationEntry({required this.credits, required this.date, this.dogName});

  final int credits;
  final DateTime date;
  final String? dogName;
}

/// "Donation & gift history": every credit the current user has ever
/// pledged, dog sponsorships and feeding-fund pledges combined, newest
/// first. Pledges are permanent/lifetime totals (see [Sponsorship.credits]
/// and [FeedingPledge]), so this is a append-only ledger, not a live balance.
class DonationHistoryPage extends StatefulWidget {
  const DonationHistoryPage({super.key});

  @override
  State<DonationHistoryPage> createState() => _DonationHistoryPageState();
}

class _DonationHistoryPageState extends State<DonationHistoryPage> {
  late Future<Either<Failure, List<_DonationEntry>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Either<Failure, List<_DonationEntry>>> _load() async {
    final sponsorshipsFuture = context.read<SponsorshipRepository>().getMySponsorships();
    final feedingPledgesFuture = context.read<AngelRepository>().getMyFeedingPledges();

    final sponsorshipsResult = await sponsorshipsFuture;
    final feedingResult = await feedingPledgesFuture;

    return sponsorshipsResult.fold(Left.new, (sponsorships) {
      return feedingResult.fold(Left.new, (feedingPledges) {
        final entries = [
          for (final s in sponsorships)
            _DonationEntry(credits: s.credits, date: s.startedAt, dogName: s.dog.name),
          for (final f in feedingPledges) _DonationEntry(credits: f.credits, date: f.createdAt),
        ]..sort((a, b) => b.date.compareTo(a.date));
        return Right(entries);
      });
    });
  }

  void _retry() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Donation & Gift History')),
      body: FutureBuilder<Either<Failure, List<_DonationEntry>>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CupertinoActivityIndicator());
          }
          return snapshot.data!.fold(
            (failure) => ErrorStateView(message: failure.message, onRetry: _retry),
            (entries) => entries.isEmpty
                ? const _EmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: entries.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) => _DonationTile(entry: entries[index]),
                  ),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.gift, size: 48, color: AppColors.bodyGray),
            const SizedBox(height: AppSpacing.md),
            Text(
              "You haven't pledged any credits yet.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.bodyGray),
            ),
          ],
        ),
      ),
    );
  }
}

class _DonationTile extends StatelessWidget {
  const _DonationTile({required this.entry});

  final _DonationEntry entry;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String get _formattedDate {
    final d = entry.date;
    return '${_months[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDog = entry.dogName != null;

    return NeoBox(
      padding: const EdgeInsets.all(AppSpacing.md),
      shadowOffset: Offset.zero,
      child: Row(
        children: [
          NeoBox(
            color: AppColors.neutralFill,
            shadowOffset: Offset.zero,
            constraints: const BoxConstraints.tightFor(width: 40, height: 40),
            alignment: Alignment.center,
            child: Icon(
              isDog ? LucideIcons.heart : LucideIcons.utensils,
              size: 18,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isDog ? 'Pledged to ${entry.dogName}' : 'Pledged to Feeding the Strays',
                  style: theme.textTheme.titleSmall,
                ),
                Text(
                  _formattedDate,
                  style: theme.textTheme.bodySmall?.copyWith(color: AppColors.bodyGray),
                ),
              ],
            ),
          ),
          Text('\$${entry.credits}/mo', style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}
