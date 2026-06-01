// Handles persistence and deduplication for the local audio library.

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/audio_track.dart';

class AudioLibraryService {
  static const _storageKey = 'orpheus_audio_library';

  final SharedPreferences _prefs;

  AudioLibraryService(this._prefs);

  Future<List<AudioTrack>> loadTracks() async {
    final raw = _prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((entry) => AudioTrack.fromJson(entry as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveTracks(List<AudioTrack> tracks) async {
    final payload = tracks.map((track) => track.toJson()).toList();
    await _prefs.setString(_storageKey, jsonEncode(payload));
  }

  List<AudioTrack> mergeTracks(
    List<AudioTrack> existing,
    List<AudioTrack> incoming,
  ) {
    final merged = <String, AudioTrack>{
      for (final track in existing) track.id: track,
    };

    for (final track in incoming) {
      merged.putIfAbsent(track.id, () => track);
    }

    final result = merged.values.toList();
    result.sort(
      (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
    );
    return result;
  }
}
