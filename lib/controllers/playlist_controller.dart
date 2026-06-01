// Coordinates playlist state and persistence.

import 'package:flutter/foundation.dart';

import '../models/audio_track.dart';
import '../models/playlist.dart';
import '../services/playlist_service.dart';

class PlaylistController extends ChangeNotifier {
  final PlaylistService _playlistService;

  List<Playlist> _playlists = [];
  bool _isLoading = false;
  String? _error;

  PlaylistController(this._playlistService);

  List<Playlist> get playlists => List.unmodifiable(_playlists);

  bool get isLoading => _isLoading;

  String? get error => _error;

  Future<void> loadPlaylists() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _playlists = await _playlistService.loadPlaylists();
    } catch (_) {
      _error = 'Unable to load playlists.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Playlist> createPlaylist({
    required String name,
    required String description,
    String? imagePath,
  }) async {
    final now = DateTime.now();
    final playlist = Playlist(
      id: Playlist.generateId(),
      name: name.trim(),
      description: description.trim(),
      imagePath: imagePath,
      trackIds: const [],
      createdAt: now,
      updatedAt: now,
    );

    _playlists = await _playlistService.upsertPlaylist(_playlists, playlist);
    notifyListeners();
    return playlist;
  }

  Future<void> updatePlaylist(Playlist playlist) async {
    final updated = playlist.copyWith(updatedAt: DateTime.now());
    _playlists = await _playlistService.upsertPlaylist(_playlists, updated);
    notifyListeners();
  }

  Future<void> deletePlaylist(String playlistId) async {
    _playlists = await _playlistService.deletePlaylist(_playlists, playlistId);
    notifyListeners();
  }

  Future<void> addTracks(String playlistId, List<AudioTrack> tracks) async {
    final trackIds = tracks.map((track) => track.id).toList();
    _playlists = await _playlistService.addTracksToPlaylist(
      playlists: _playlists,
      playlistId: playlistId,
      trackIds: trackIds,
    );
    notifyListeners();
  }

  Future<void> removeTrack(String playlistId, String trackId) async {
    _playlists = await _playlistService.removeTrackFromPlaylist(
      playlists: _playlists,
      playlistId: playlistId,
      trackId: trackId,
    );
    notifyListeners();
  }

  List<AudioTrack> tracksForPlaylist(
    Playlist playlist,
    List<AudioTrack> allTracks,
  ) {
    final byId = {for (final track in allTracks) track.id: track};
    final ordered = <AudioTrack>[];

    for (final trackId in playlist.trackIds) {
      final track = byId[trackId];
      if (track != null) {
        ordered.add(track);
      }
    }

    return ordered;
  }
}
