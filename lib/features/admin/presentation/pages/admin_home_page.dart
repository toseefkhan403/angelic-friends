import 'package:brutalist_ui/brutalist_ui.dart' show NeoBox;
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sponsor_a_dog/core/constants/app_spacing.dart';
import 'package:sponsor_a_dog/core/theme/app_colors.dart';
import 'package:sponsor_a_dog/features/admin/presentation/pages/admin_angels_page.dart';
import 'package:sponsor_a_dog/features/admin/presentation/pages/admin_weekly_updates_page.dart';

/// Entry point for the admin-only tooling — visible in Profile only when
/// `AuthRepository.isAdmin` is true. Real enforcement is server-side (RLS +
/// `is_admin()`), this page is just a menu.
class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _AdminMenuTile(
            icon: LucideIcons.messageCircle,
            title: 'Reply to Angels',
            subtitle: "See every sponsor's thread and reply as the handler.",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminAngelsPage()),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _AdminMenuTile(
            icon: LucideIcons.video,
            title: 'Send Weekly Updates',
            subtitle: 'Broadcast a video to a dog\'s eligible sponsors.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminWeeklyUpdatesPage()),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminMenuTile extends StatelessWidget {
  const _AdminMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: NeoBox(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Icon(icon, color: AppColors.ink, size: 28),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
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
