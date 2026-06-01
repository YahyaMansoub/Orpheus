// Handles persistence and updates for playlists.

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/playlist.dart';

class PlaylistService {
  static const _storageKey = 'orpheus_playlists';

  final SharedPreferences _prefs;

  PlaylistService(this._prefs);

  Future<List<Playlist>> loadPlaylists() async {
    final raw = _prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(Playlist.fromJson)
        .toList();
  }

  Future<void> savePlaylists(List<Playlist> playlists) async {
    final payload = playlists.map((playlist) => playlist.toJson()).toList();
    await _prefs.setString(_storageKey, jsonEncode(payload));
  }

  Future<List<Playlist>> upsertPlaylist(
    List<Playlist> playlists,
    Playlist playlist,
  ) async {
    final updated = _replacePlaylist(playlists, playlist);
    await savePlaylists(updated);
    return updated;
  }

  Future<List<Playlist>> deletePlaylist(
    List<Playlist> playlists,
    String playlistId,
  ) async {
    final updated = playlists.where((item) => item.id != playlistId).toList();
    await savePlaylists(updated);
    return updated;
  }

  Future<List<Playlist>> addTracksToPlaylist({
    required List<Playlist> playlists,
    required String playlistId,
    required List<String> trackIds,
  }) async {
    if (trackIds.isEmpty) {
      return playlists;
    }

    final now = DateTime.now();
    final updated = playlists.map((playlist) {
      if (playlist.id != playlistId) {
        return playlist;
      }

      final existing = playlist.trackIds.toList();
      final existingSet = existing.toSet();
      final incoming = trackIds.where((id) => !existingSet.contains(id));
      final merged = [...existing, ...incoming];

      return playlist.copyWith(trackIds: merged, updatedAt: now);
    }).toList();

    await savePlaylists(updated);
    return updated;
  }

  Future<List<Playlist>> removeTrackFromPlaylist({
    required List<Playlist> playlists,
    required String playlistId,
    required String trackId,
  }) async {
    final now = DateTime.now();
    final updated = playlists.map((playlist) {
      if (playlist.id != playlistId) {
        return playlist;
      }

      final filtered = playlist.trackIds.where((id) => id != trackId).toList();
      if (filtered.length == playlist.trackIds.length) {
        return playlist;
      }

      return playlist.copyWith(trackIds: filtered, updatedAt: now);
    }).toList();

    await savePlaylists(updated);
    return updated;
  }

  List<Playlist> _replacePlaylist(List<Playlist> playlists, Playlist playlist) {
    final updated = playlists.toList();
    final index = updated.indexWhere((item) => item.id == playlist.id);

    if (index >= 0) {
      updated[index] = playlist;
    } else {
      updated.add(playlist);
    }

    updated.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return updated;
  }
}
