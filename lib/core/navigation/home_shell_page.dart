import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sponsor_a_dog/features/dogs/presentation/pages/explore_page.dart';
import 'package:sponsor_a_dog/features/profile/presentation/pages/profile_page.dart';
import 'package:sponsor_a_dog/features/sponsors/presentation/pages/my_dogs_page.dart';

/// Top-level 3-tab shell (PRODUCT_SPEC.md §3): Explore, My Dogs, Profile.
class HomeShellPage extends StatefulWidget {
  const HomeShellPage({super.key});

  @override
  State<HomeShellPage> createState() => _HomeShellPageState();
}

class _HomeShellPageState extends State<HomeShellPage> {
  int _index = 0;

  void _goToExplore() => setState(() => _index = 0);

  void _goToProfile() => setState(() => _index = 2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          ExplorePage(onProfileTap: _goToProfile),
          MyDogsPage(onExplore: _goToExplore),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(LucideIcons.compass),
            selectedIcon: Icon(LucideIcons.compass),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.heart),
            selectedIcon: Icon(LucideIcons.heart),
            label: 'My Dogs',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.user),
            selectedIcon: Icon(LucideIcons.user),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
