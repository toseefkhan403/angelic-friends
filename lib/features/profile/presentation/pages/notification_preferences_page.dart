import 'package:brutalist_ui/brutalist_ui.dart' show NeoBox;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sponsor_a_dog/core/constants/app_spacing.dart';
import 'package:sponsor_a_dog/core/theme/app_colors.dart';

/// Local, on-device notification toggles. There's no push-notification
/// backend wired up yet (no FCM token registration, no send pipeline) — this
/// only persists the user's preference on their own device via
/// [SharedPreferences], for whenever that pipeline exists to read it. It is
/// deliberately not backed by a server table.
class NotificationPreferencesPage extends StatefulWidget {
  const NotificationPreferencesPage({super.key});

  static const dogUpdatesKey = 'notif_pref_dog_updates';
  static const chatMessagesKey = 'notif_pref_chat_messages';
  static const promotionsKey = 'notif_pref_promotions';

  @override
  State<NotificationPreferencesPage> createState() => _NotificationPreferencesPageState();
}

class _NotificationPreferencesPageState extends State<NotificationPreferencesPage> {
  SharedPreferences? _prefs;
  bool _dogUpdates = true;
  bool _chatMessages = true;
  bool _promotions = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _prefs = prefs;
      _dogUpdates = prefs.getBool(NotificationPreferencesPage.dogUpdatesKey) ?? true;
      _chatMessages = prefs.getBool(NotificationPreferencesPage.chatMessagesKey) ?? true;
      _promotions = prefs.getBool(NotificationPreferencesPage.promotionsKey) ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Preferences')),
      body: _prefs == null
          ? const Center(child: CupertinoActivityIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                _PreferenceTile(
                  title: 'Dog updates',
                  subtitle: "New photos and videos from a dog you've sponsored.",
                  value: _dogUpdates,
                  onChanged: (value) {
                    setState(() => _dogUpdates = value);
                    _prefs!.setBool(NotificationPreferencesPage.dogUpdatesKey, value);
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                _PreferenceTile(
                  title: 'Chat messages',
                  subtitle: 'New messages from a handler you can chat with.',
                  value: _chatMessages,
                  onChanged: (value) {
                    setState(() => _chatMessages = value);
                    _prefs!.setBool(NotificationPreferencesPage.chatMessagesKey, value);
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                _PreferenceTile(
                  title: 'News & promotions',
                  subtitle: 'Occasional updates about Angelic Friends.',
                  value: _promotions,
                  onChanged: (value) {
                    setState(() => _promotions = value);
                    _prefs!.setBool(NotificationPreferencesPage.promotionsKey, value);
                  },
                ),
              ],
            ),
    );
  }
}

class _PreferenceTile extends StatelessWidget {
  const _PreferenceTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return NeoBox(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      shadowOffset: Offset.zero,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: theme.textTheme.titleSmall),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(color: AppColors.bodyGray),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
