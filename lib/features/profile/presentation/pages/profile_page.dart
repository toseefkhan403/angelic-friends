import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sponsor_a_dog/core/auth/auth_repository.dart';
import 'package:sponsor_a_dog/core/constants/app_spacing.dart';
import 'package:sponsor_a_dog/core/theme/app_colors.dart';

/// The "Profile" tab. Lays out the sections from PRODUCT_SPEC.md §4.11;
/// most are not wired up yet — see docs/DATABASE_SCHEMA.md for what's
/// still missing beyond auth (sign-in/out is backed by Supabase auth).
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
            onTap: () => context.read<AuthRepository>().signOut(),
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
