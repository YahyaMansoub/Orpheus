// Main navigation hub with quick access cards.

import 'package:flutter/material.dart';

import '../app/app_routes.dart';
import '../controllers/player_controller.dart';
import '../widgets/app_drawer.dart';
import '../widgets/mini_player.dart';

class HomeScreen extends StatelessWidget {
  final PlayerController playerController;

  const HomeScreen({super.key, required this.playerController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orpheus')),
      drawer: const AppDrawer(currentRoute: AppRoutes.home),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _NavigationCard(
              icon: Icons.radar,
              title: 'Radar',
              subtitle: 'Scan and manage your audio library.',
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.radar),
            ),
            const SizedBox(height: 12),
            _NavigationCard(
              icon: Icons.queue_music,
              title: 'Playlists',
              subtitle: 'Curated mixes and collections.',
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.playlists),
            ),
            const SizedBox(height: 12),
            _NavigationCard(
              icon: Icons.settings,
              title: 'Settings',
              subtitle: 'Theme and app preferences.',
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.settings),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: playerController,
        builder: (context, _) {
          if (!playerController.hasTrack) {
            return const SizedBox.shrink();
          }
          return MiniPlayer(
            playerController: playerController,
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.player),
          );
        },
      ),
    );
  }
}

class _NavigationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _NavigationCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(icon),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(subtitle),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
