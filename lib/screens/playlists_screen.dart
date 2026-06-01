// Playlist library screen with creation entry point.

import 'dart:io';

import 'package:flutter/material.dart';

import '../app/app_routes.dart';
import '../controllers/library_controller.dart';
import '../controllers/playlist_controller.dart';
import '../controllers/player_controller.dart';
import '../models/playlist.dart';
import '../widgets/app_drawer.dart';
import '../widgets/empty_state.dart';
import '../widgets/mini_player.dart';
import 'playlist_details_screen.dart';
import 'playlist_editor_screen.dart';

class PlaylistsScreen extends StatelessWidget {
  final PlaylistController playlistController;
  final LibraryController libraryController;
  final PlayerController playerController;

  const PlaylistsScreen({
    super.key,
    required this.playlistController,
    required this.libraryController,
    required this.playerController,
  });

  void _openCreatePlaylist(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            PlaylistEditorScreen(playlistController: playlistController),
      ),
    );
  }

  void _openDetails(BuildContext context, Playlist playlist) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlaylistDetailsScreen(
          playlistId: playlist.id,
          playlistController: playlistController,
          libraryController: libraryController,
          playerController: playerController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Playlists')),
      drawer: const AppDrawer(currentRoute: AppRoutes.playlists),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCreatePlaylist(context),
        child: const Icon(Icons.add),
      ),
      body: AnimatedBuilder(
        animation: playlistController,
        builder: (context, _) {
          if (playlistController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (playlistController.error != null) {
            return EmptyState(
              title: playlistController.error!,
              subtitle: 'Pull down to try again later.',
              icon: Icons.error_outline,
            );
          }

          final playlists = playlistController.playlists;
          if (playlists.isEmpty) {
            return const EmptyState(
              title: 'No playlists yet.',
              subtitle: 'Tap + to build your first playlist.',
              icon: Icons.queue_music,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 120, left: 16, right: 16),
            itemCount: playlists.length,
            itemBuilder: (context, index) {
              final playlist = playlists[index];
              return _PlaylistCard(
                playlist: playlist,
                onTap: () => _openDetails(context, playlist),
              );
            },
            separatorBuilder: (_, _) => const SizedBox(height: 12),
          );
        },
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

class _PlaylistCard extends StatelessWidget {
  final Playlist playlist;
  final VoidCallback onTap;

  const _PlaylistCard({required this.playlist, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _PlaylistArtwork(imagePath: playlist.imagePath),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playlist.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      playlist.description.isNotEmpty
                          ? playlist.description
                          : 'No description yet.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${playlist.trackIds.length} tracks',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
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

class _PlaylistArtwork extends StatelessWidget {
  final String? imagePath;

  const _PlaylistArtwork({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final size = 64.0;
    final path = imagePath;

    if (path != null && path.isNotEmpty) {
      final file = File(path);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(file, width: size, height: size, fit: BoxFit.cover),
        );
      }
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.queue_music),
    );
  }
}
