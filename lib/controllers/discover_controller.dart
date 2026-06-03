// Manages Jamendo discovery state and download workflow.

import 'package:flutter/foundation.dart';

import '../models/audio_track.dart';
import '../models/jamendo_track.dart';
import '../services/download_service.dart';
import '../services/jamendo_api_service.dart';
import 'library_controller.dart';

class DiscoverController extends ChangeNotifier {
  final JamendoApiService _apiService;
  final DownloadService _downloadService;
  final LibraryController _libraryController;

  DiscoverController({
    required this._apiService,
    required this._downloadService,
    required this._libraryController,
  });

  // Keep this here so we do not leak the API key into source.
  static const jamendoClientId = String.fromEnvironment('JAMENDO_CLIENT_ID');

  List<JamendoTrack> _results = [];
  bool _isLoading = false;
  String? _error;
  bool _missingApiKey = false;

  List<JamendoTrack> get results => List.unmodifiable(_results);

  bool get isLoading => _isLoading;

  String? get error => _error;

  bool get missingApiKey => _missingApiKey;

  Future<void> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      _results = [];
      _error = null;
      _missingApiKey = false;
      notifyListeners();
      return;
    }

    if (jamendoClientId.trim().isEmpty) {
      _results = [];
      _missingApiKey = true;
      _error =
          'Jamendo API key is missing. Run with --dart-define=JAMENDO_CLIENT_ID=...';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    _missingApiKey = false;
    notifyListeners();

    try {
      _results = await _apiService.searchTracks(
        query: trimmed,
        clientId: jamendoClientId,
      );
    } catch (_) {
      _error = 'Unable to fetch Jamendo results.';
      _results = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool canDownload(JamendoTrack track) => track.canDownload;

  Future<AudioTrack?> downloadTrack(JamendoTrack track) async {
    if (!track.canDownload) {
      return null;
    }

    final saved = await _downloadService.downloadTrack(track);
    if (saved == null) {
      return null;
    }

    final alreadyInLibrary = _libraryController.tracks.any(
      (item) => item.id == saved.id,
    );

    if (!alreadyInLibrary) {
      await _libraryController.addTracks([saved]);
    }

    return saved;
  }
}
