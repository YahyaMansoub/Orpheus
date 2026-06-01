// Coordinates library loading, persistence, and file imports.

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import '../models/audio_track.dart';
import '../services/audio_library_service.dart';

class LibraryController extends ChangeNotifier {
  final AudioLibraryService _libraryService;

  List<AudioTrack> _tracks = [];
  bool _isLoading = false;
  String? _error;

  LibraryController(this._libraryService);

  List<AudioTrack> get tracks => List.unmodifiable(_tracks);

  bool get isLoading => _isLoading;

  String? get error => _error;

  bool get hasTracks => _tracks.isNotEmpty;

  Future<void> loadLibrary() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tracks = await _libraryService.loadTracks();
    } catch (_) {
      _error = 'Unable to load your library.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTracks(List<AudioTrack> tracks) async {
    if (tracks.isEmpty) {
      return;
    }

    _tracks = _libraryService.mergeTracks(_tracks, tracks);
    await _libraryService.saveTracks(_tracks);
    notifyListeners();
  }

  Future<void> addTracksFromFilePicker() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'm4a', 'aac', 'flac'],
      allowMultiple: true,
    );

    if (result == null) {
      return;
    }

    final picked = result.files
        .where((file) => file.path != null)
        .map((file) => AudioTrack.fromFile(name: file.name, path: file.path!))
        .toList();

    await addTracks(picked);
  }

  bool isMissing(AudioTrack track) {
    if (!track.isFileSource) {
      return false;
    }

    return !File.fromUri(track.audioUri).existsSync();
  }

  List<AudioTrack> playableTracks() {
    return _tracks.where((track) => !isMissing(track)).toList();
  }
}
