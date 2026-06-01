import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:orpheus/models/audio_track.dart';
import 'package:orpheus/services/audio_library_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('AudioLibraryService deduplicates tracks by id', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final service = AudioLibraryService(prefs);

    final trackA = AudioTrack.fromFile(name: 'Song A', path: '/tmp/a.mp3');
    final trackB = AudioTrack.fromFile(name: 'Song A', path: '/tmp/a.mp3');

    final merged = service.mergeTracks([trackA], [trackB]);
    expect(merged.length, 1);
  });
}
