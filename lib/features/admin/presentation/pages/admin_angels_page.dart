import 'package:brutalist_ui/brutalist_ui.dart' show NeoBadge, NeoBox;
import 'package:dartz/dartz.dart' show Either;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sponsor_a_dog/core/constants/app_spacing.dart';
import 'package:sponsor_a_dog/core/error/failures.dart';
import 'package:sponsor_a_dog/core/theme/app_colors.dart';
import 'package:sponsor_a_dog/core/widgets/async_state_view.dart';
import 'package:sponsor_a_dog/features/admin/domain/entities/admin_sponsorship_overview.dart';
import 'package:sponsor_a_dog/features/admin/domain/repositories/admin_repository.dart';
import 'package:sponsor_a_dog/features/admin/presentation/pages/admin_chat_thread_page.dart';

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// Every sponsor's ("Angel") thread, needs-reply first — the admin's inbox.
class AdminAngelsPage extends StatefulWidget {
  const AdminAngelsPage({super.key});

  @override
  State<AdminAngelsPage> createState() => _AdminAngelsPageState();
}

class _AdminAngelsPageState extends State<AdminAngelsPage> {
  late Future<Either<Failure, List<AdminSponsorshipOverview>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Either<Failure, List<AdminSponsorshipOverview>>> _load() =>
      context.read<AdminRepository>().getAngelOverviews();

  void _retry() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Angels')),
      body: FutureBuilder<Either<Failure, List<AdminSponsorshipOverview>>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CupertinoActivityIndicator());
          }
          return snapshot.data!.fold(
            (failure) => ErrorStateView(message: failure.message, onRetry: _retry),
            (overviews) => overviews.isEmpty
                ? const _EmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: overviews.length,
                    separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) => _AngelTile(overview: overviews[index]),
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
            const Icon(LucideIcons.messageCircle, size: 48, color: AppColors.bodyGray),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No sponsorships yet.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.bodyGray),
            ),
          ],
        ),
      ),
    );
  }
}

class _AngelTile extends StatelessWidget {
  const _AngelTile({required this.overview});

  final AdminSponsorshipOverview overview;

  String get _lastActivityLabel {
    final d = overview.lastMessageAt;
    if (d == null) return 'No messages yet';
    return '${_months[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AdminChatThreadPage(overview: overview)),
      ),
      child: NeoBox(
        padding: const EdgeInsets.all(AppSpacing.md),
        shadowOffset: Offset.zero,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(overview.angelName, style: theme.textTheme.titleSmall),
                      ),
                      if (overview.needsReply) ...[
                        const SizedBox(width: 4),
                        const NeoBadge(child: Text('Needs reply')),
                      ],
                    ],
                  ),
                  Text(
                    '${overview.dogName} · \$${overview.credits}/mo',
                    style: theme.textTheme.bodySmall?.copyWith(color: AppColors.bodyGray),
                  ),
                  Text(
                    _lastActivityLabel,
                    style: theme.textTheme.bodySmall?.copyWith(color: AppColors.bodyGray),
                  ),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, color: AppColors.bodyGray),
          ],
        ),
      ),
    );
  }
}
