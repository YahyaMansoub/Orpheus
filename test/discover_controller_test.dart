import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:orpheus/controllers/discover_controller.dart';
import 'package:orpheus/controllers/library_controller.dart';
import 'package:orpheus/models/jamendo_track.dart';
import 'package:orpheus/services/audio_library_service.dart';
import 'package:orpheus/services/download_service.dart';
import 'package:orpheus/services/jamendo_api_service.dart';

class _FakeApiService extends JamendoApiService {
  @override
  Future<List<JamendoTrack>> searchTracks({
    required String query,
    required String clientId,
  }) async {
    return [];
  }
}

class _FakeDownloadService extends DownloadService {}

void main() {
  test('DiscoverController reports missing API key', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final libraryController = LibraryController(AudioLibraryService(prefs));

    final controller = DiscoverController(
      apiService: _FakeApiService(),
      downloadService: _FakeDownloadService(),
      libraryController: libraryController,
    );

    await controller.search('lofi');

    expect(controller.missingApiKey, true);
    expect(controller.error, isNotNull);
    expect(controller.results, isEmpty);
  });

  test('DiscoverController download visibility mirrors track', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final track = JamendoTrack.fromJson({
      'id': '1',
      'name': 'Track',
      'artist_name': 'Artist',
      'audio': 'https://audio.example/stream.mp3',
      'audiodownload_allowed': true,
      'audiodownload': 'https://audio.example/download.mp3',
      'duration': 10,
    });

    final controller = DiscoverController(
      apiService: _FakeApiService(),
      downloadService: _FakeDownloadService(),
      libraryController: LibraryController(AudioLibraryService(prefs)),
    );

    expect(controller.canDownload(track), true);
  });
}
