import 'package:flutter_test/flutter_test.dart';
import 'package:orpheus/models/jamendo_track.dart';

void main() {
  test('JamendoTrack parses JSON fields', () {
    final track = JamendoTrack.fromJson({
      'id': '123',
      'name': 'Test Track',
      'artist_name': 'Test Artist',
      'album_name': 'Test Album',
      'image': 'https://img.example/cover.jpg',
      'audio': 'https://audio.example/stream.mp3',
      'audiodownload': 'https://audio.example/download.mp3',
      'audiodownload_allowed': true,
      'license_ccurl': 'https://license.example/cc',
      'duration': 210,
    });

    expect(track.id, '123');
    expect(track.name, 'Test Track');
    expect(track.artistName, 'Test Artist');
    expect(track.albumName, 'Test Album');
    expect(track.image, 'https://img.example/cover.jpg');
    expect(track.audio, 'https://audio.example/stream.mp3');
    expect(track.audioDownload, 'https://audio.example/download.mp3');
    expect(track.audioDownloadAllowed, true);
    expect(track.licenseCcurl, 'https://license.example/cc');
    expect(track.duration, 210);
    expect(track.canDownload, true);
  });
}
