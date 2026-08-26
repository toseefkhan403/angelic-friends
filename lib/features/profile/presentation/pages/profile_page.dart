import 'package:brutalist_ui/brutalist_ui.dart' show NeoBox, NeoButton;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:sponsor_a_dog/core/auth/auth_repository.dart';
import 'package:sponsor_a_dog/core/constants/app_spacing.dart';
import 'package:sponsor_a_dog/core/purchases/purchases_service.dart';
import 'package:sponsor_a_dog/core/theme/app_colors.dart';
import 'package:sponsor_a_dog/core/widgets/tab_refresh_listener.dart';
import 'package:sponsor_a_dog/features/angel/domain/entities/angel_subscription.dart';
import 'package:sponsor_a_dog/features/angel/domain/repositories/angel_repository.dart';
import 'package:sponsor_a_dog/features/angel/domain/usecases/get_my_angel_subscription.dart';
import 'package:sponsor_a_dog/features/profile/presentation/bloc/angel_status_bloc.dart';

/// The "Profile" tab. Lays out the sections from PRODUCT_SPEC.md §4.11;
/// most are not wired up yet — see docs/DATABASE_SCHEMA.md for what's
/// still missing beyond auth (sign-in/out is backed by Supabase auth) and
/// the Angel subscription status (backed by [AngelStatusBloc]).
class ProfilePage extends StatelessWidget {
  const ProfilePage({this.isActive = true, super.key});

  /// Whether this tab is the one currently visible in the bottom-nav
  /// `IndexedStack` — when it flips from false to true (the user switching
  /// back to this tab), the Angel status is refetched so a purchase/pledge
  /// made elsewhere (e.g. the dog detail page) shows up here too.
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AngelStatusBloc(
        getMyAngelSubscription: GetMyAngelSubscription(context.read<AngelRepository>()),
      )..add(const AngelStatusFetchRequested()),
      child: TabRefreshListener(
        isActive: isActive,
        onActivated: (context) =>
            context.read<AngelStatusBloc>().add(const AngelStatusFetchRequested()),
        child: const _ProfileView(),
      ),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayName = context.read<AuthRepository>().displayName;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.neutralFill,
                  border: Border.all(color: AppColors.ink, width: 2),
                ),
                child: const Icon(LucideIcons.user, color: AppColors.ink, size: 28),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(displayName ?? 'Friend', style: theme.textTheme.titleMedium),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const _AngelStatusCard(),
          const SizedBox(height: AppSpacing.lg),
          const Divider(),
          const _ProfileTile(
            icon: LucideIcons.award,
            label: 'Manage subscription',
          ),
          const _ProfileTile(
            icon: LucideIcons.gift,
            label: 'Donation & gift history',
          ),
          const _ProfileTile(
            icon: LucideIcons.bell,
            label: 'Notification preferences',
          ),
          const _ProfileTile(icon: LucideIcons.helpCircle, label: 'Support'),
          const _ProfileTile(icon: LucideIcons.fileText, label: 'Privacy policy & terms'),
          const Divider(),
          _ProfileTile(
            icon: LucideIcons.logOut,
            label: 'Sign out',
            onTap: () async {
              final authRepository = context.read<AuthRepository>();
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context, rootNavigator: true);
              final result = await authRepository.signOut();
              result.fold(
                (failure) => messenger.showSnackBar(SnackBar(content: Text(failure.message))),
                // `_AppRoot`'s StreamBuilder swaps to OnboardingIntroPage once
                // the auth stream reflects this, but that swap only replaces
                // the base route — if the user reached this tile with other
                // pages pushed on top (dog detail, chat, ...), those would
                // otherwise still cover it. Popping to root makes sure it's
                // actually visible.
                (_) => navigator.popUntil((route) => route.isFirst),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Shows the user's Angel credit balance, or a prompt to become one.
class _AngelStatusCard extends StatelessWidget {
  const _AngelStatusCard();

  Future<void> _becomeAnAngel(BuildContext context) async {
    final purchasesService = context.read<PurchasesService>();
    final messenger = ScaffoldMessenger.of(context);

    if (!purchasesService.isAvailable) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Purchases are not available on this platform.')),
      );
      return;
    }

    try {
      await RevenueCatUI.presentPaywall();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text("Couldn't open the paywall: $e")));
    }

    if (!context.mounted) return;
    context.read<AngelStatusBloc>().add(const AngelStatusFetchRequested());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<AngelStatusBloc, AngelStatusState>(
      builder: (context, state) {
        return switch (state) {
          AngelStatusInitial() || AngelStatusLoading() => const NeoBox(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Center(child: CupertinoActivityIndicator()),
            ),
          AngelStatusFailure() => const SizedBox.shrink(),
          AngelStatusLoaded(:final subscription) =>
            subscription != null && subscription.isActive
                ? _ActiveAngelCard(subscription: subscription)
                : NeoBox(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Not an Angel yet', style: theme.textTheme.titleMedium),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Become an Angel to get monthly credits you can pledge to any '
                          'dogs you choose.',
                          style: theme.textTheme.bodySmall?.copyWith(color: AppColors.bodyGray),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SizedBox(
                          width: double.infinity,
                          child: NeoButton(
                            onPressed: () => _becomeAnAngel(context),
                            child: const Text('Become an Angel'),
                          ),
                        ),
                      ],
                    ),
                  ),
        };
      },
    );
  }
}

class _ActiveAngelCard extends StatelessWidget {
  const _ActiveAngelCard({required this.subscription});

  final AngelSubscription subscription;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return NeoBox(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          const Icon(LucideIcons.sparkles, color: AppColors.ink),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Angel · \$${subscription.monthlyCredits}/mo', style: theme.textTheme.titleMedium),
                Text(
                  '${subscription.availableCredits} credits available to pledge',
                  style: theme.textTheme.bodySmall?.copyWith(color: AppColors.bodyGray),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.ink),
      title: Text(label),
      trailing: const Icon(LucideIcons.chevronRight, color: AppColors.bodyGray),
      onTap: onTap ??
          () => ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Coming soon'))),
    );
  }
}
