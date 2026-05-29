// Displays all user-imported audio files.

import 'package:flutter/material.dart';

import '../app/app_routes.dart';
import '../controllers/library_controller.dart';
import '../controllers/player_controller.dart';
import '../widgets/app_drawer.dart';
import '../widgets/empty_state.dart';
import '../widgets/mini_player.dart';
import '../widgets/track_tile.dart';

class GeneralDownloadsScreen extends StatelessWidget {
  final LibraryController libraryController;
  final PlayerController playerController;

  const GeneralDownloadsScreen({
    super.key,
    required this.libraryController,
    required this.playerController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('General Downloads')),
      drawer: const AppDrawer(currentRoute: AppRoutes.generalDownloads),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: libraryController.addTracksFromFilePicker,
        child: const Icon(Icons.add),
      ),
      body: AnimatedBuilder(
        animation: libraryController,
        builder: (context, _) {
          if (libraryController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (libraryController.error != null) {
            return EmptyState(
              title: libraryController.error!,
              subtitle: 'Pull down to try again later.',
              icon: Icons.error_outline,
            );
          }

          if (!libraryController.hasTracks) {
            return const EmptyState(
              title: 'No songs yet.',
              subtitle: 'Tap + to add audio files from your device.',
            );
          }

          final playableQueue = libraryController.playableTracks();
          final currentTrack = playerController.currentTrack;

          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 120),
            itemCount: libraryController.tracks.length,
            itemBuilder: (context, index) {
              final track = libraryController.tracks[index];
              final isActive = track.id == currentTrack?.id;
              final isMissing = libraryController.isMissing(track);

              return TrackTile(
                track: track,
                isActive: isActive,
                isMissing: isMissing,
                onTap: () => playerController.playTrack(track, playableQueue),
              );
            },
            separatorBuilder: (_, _) => const Divider(height: 1),
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
