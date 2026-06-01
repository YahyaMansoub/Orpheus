import 'package:flutter/material.dart';

import '../controllers/library_controller.dart';
import '../controllers/playlist_controller.dart';
import '../models/audio_track.dart';
import '../models/playlist.dart';
import '../widgets/empty_state.dart';

class PlaylistTrackPickerScreen extends StatefulWidget {
  final Playlist playlist;
  final PlaylistController playlistController;
  final LibraryController libraryController;

  const PlaylistTrackPickerScreen({
    super.key,
    required this.playlist,
    required this.playlistController,
    required this.libraryController,
  });

  @override
  State<PlaylistTrackPickerScreen> createState() =>
      _PlaylistTrackPickerScreenState();
}

class _PlaylistTrackPickerScreenState extends State<PlaylistTrackPickerScreen> {
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    final tracks = widget.libraryController.tracks;
    final existingIds = widget.playlist.trackIds.toSet();

    return Scaffold(
      appBar: AppBar(title: const Text('Add tracks')),
      body: tracks.isEmpty
          ? const EmptyState(
              title: 'No tracks in your library.',
              subtitle: 'Add songs to your library first.',
              icon: Icons.library_music,
            )
          : ListView.separated(
              padding: const EdgeInsets.only(bottom: 120),
              itemCount: tracks.length,
              itemBuilder: (context, index) {
                final track = tracks[index];
                final alreadyAdded = existingIds.contains(track.id);
                final selected = _selected.contains(track.id);

                return CheckboxListTile(
                  value: alreadyAdded ? true : selected,
                  onChanged: alreadyAdded
                      ? null
                      : (value) {
                          setState(() {
                            if (value == true) {
                              _selected.add(track.id);
                            } else {
                              _selected.remove(track.id);
                            }
                          });
                        },
                  title: Text(
                    track.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    alreadyAdded ? 'Already in playlist' : track.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  secondary: const Icon(Icons.audiotrack),
                );
              },
              separatorBuilder: (_, _) => const Divider(height: 1),
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _selected.isEmpty ? null : _addTracks,
            child: Text('Add ${_selected.length} tracks'),
          ),
        ),
      ),
    );
  }

  Future<void> _addTracks() async {
    final selectedTracks = _selected
        .map(_findTrackById)
        .whereType<AudioTrack>()
        .toList();

    await widget.playlistController.addTracks(
      widget.playlist.id,
      selectedTracks,
    );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  AudioTrack? _findTrackById(String id) {
    return widget.libraryController.tracks
        .where((track) => track.id == id)
        .firstOrNull;
  }
}

extension on Iterable<AudioTrack> {
  AudioTrack? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) {
      return null;
    }
    return iterator.current;
  }
}
