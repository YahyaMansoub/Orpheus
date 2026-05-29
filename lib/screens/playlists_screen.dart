// Placeholder page for future playlist management.

import 'package:flutter/material.dart';

import '../app/app_routes.dart';
import '../widgets/app_drawer.dart';
import '../widgets/empty_state.dart';

class PlaylistsScreen extends StatelessWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Playlists')),
      drawer: const AppDrawer(currentRoute: AppRoutes.playlists),
      body: const EmptyState(
        title: 'Playlists are coming soon.',
        subtitle: 'This space will hold your custom mixes.',
        icon: Icons.queue_music,
      ),
    );
  }
}
