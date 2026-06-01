import 'dart:io';

import 'package:flutter/material.dart';

import '../app/app_routes.dart';
import '../controllers/library_controller.dart';
import '../controllers/playlist_controller.dart';
import '../controllers/player_controller.dart';
import '../models/audio_track.dart';
import '../models/playlist.dart';
import '../widgets/empty_state.dart';
import '../widgets/mini_player.dart';
import 'playlist_editor_screen.dart';
import 'playlist_track_picker_screen.dart';

class PlaylistDetailsScreen extends StatelessWidget {
  final String playlistId;
  final PlaylistController playlistController;
  final LibraryController libraryController;
  final PlayerController playerController;

  const PlaylistDetailsScreen({
    super.key,
    required this.playlistId,
    required this.playlistController,
    required this.libraryController,
    required this.playerController,
  });

  Future<void> _confirmDelete(BuildContext context, Playlist playlist) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete playlist?'),
        content: Text('Delete "${playlist.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await playlistController.deletePlaylist(playlist.id);
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  void _openEditor(BuildContext context, Playlist playlist) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlaylistEditorScreen(
          playlistController: playlistController,
          playlist: playlist,
        ),
      ),
    );
  }

  void _openTrackPicker(BuildContext context, Playlist playlist) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlaylistTrackPickerScreen(
          playlist: playlist,
          playlistController: playlistController,
          libraryController: libraryController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: playlistController,
      builder: (context, _) {
        final playlist = playlistController.playlists
            .where((item) => item.id == playlistId)
            .firstOrNull;

        if (playlist == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Playlist')),
            body: const EmptyState(
              title: 'Playlist not found.',
              subtitle: 'It may have been removed already.',
              icon: Icons.error_outline,
            ),
          );
        }

        final playlistTracks = playlistController.tracksForPlaylist(
          playlist,
          libraryController.tracks,
        );
        final playableQueue = playlistTracks
            .where((track) => !libraryController.isMissing(track))
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: Text(playlist.name),
            actions: [
              IconButton(
                tooltip: 'Edit playlist',
                icon: const Icon(Icons.edit),
                onPressed: () => _openEditor(context, playlist),
              ),
              IconButton(
                tooltip: 'Delete playlist',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _confirmDelete(context, playlist),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 120),
            children: [
              _HeaderCard(playlist: playlist),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => _openTrackPicker(context, playlist),
                icon: const Icon(Icons.add),
                label: const Text('Add tracks'),
              ),
              const SizedBox(height: 16),
              Text('Tracks', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (playlistTracks.isEmpty)
                const EmptyState(
                  title: 'No tracks in this playlist.',
                  subtitle: 'Add tracks to start listening.',
                  icon: Icons.queue_music,
                )
              else
                ...playlistTracks.map(
                  (track) => _PlaylistTrackTile(
                    track: track,
                    isMissing: libraryController.isMissing(track),
                    isActive: track.id == playerController.currentTrack?.id,
                    onTap: () =>
                        playerController.playTrack(track, playableQueue),
                    onRemove: () =>
                        playlistController.removeTrack(playlist.id, track.id),
                  ),
                ),
            ],
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
      },
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final Playlist playlist;

  const _HeaderCard({required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PlaylistArtwork(imagePath: playlist.imagePath),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    playlist.description.isNotEmpty
                        ? playlist.description
                        : 'No description yet.',
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${playlist.trackIds.length} tracks',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
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
    final size = 92.0;
    final path = imagePath;

    if (path != null && path.isNotEmpty) {
      final file = File(path);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(file, width: size, height: size, fit: BoxFit.cover),
        );
      }
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.queue_music, size: 40),
    );
  }
}

class _PlaylistTrackTile extends StatelessWidget {
  final AudioTrack track;
  final bool isActive;
  final bool isMissing;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _PlaylistTrackTile({
    required this.track,
    required this.isActive,
    required this.isMissing,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final icon = isMissing
        ? Icons.music_off
        : isActive
        ? Icons.equalizer
        : Icons.music_note;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          isMissing ? 'Missing file' : track.subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          tooltip: 'Remove track',
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: onRemove,
        ),
        onTap: isMissing ? null : onTap,
      ),
    );
  }
}

extension on Iterable<Playlist> {
  Playlist? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) {
      return null;
    }
    return iterator.current;
  }
}
