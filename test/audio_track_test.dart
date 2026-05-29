import 'package:flutter_test/flutter_test.dart';

import 'package:orpheus/models/audio_track.dart';

void main() {
  test('AudioTrack serializes and restores', () {
    final track = AudioTrack.fromFile(name: 'Song A', path: '/tmp/song.mp3');
    final json = track.toJson();
    final restored = AudioTrack.fromJson(json);

    expect(restored.id, track.id);
    expect(restored.title, track.title);
    expect(restored.uri, track.uri);
    expect(restored.source, AudioSourceType.file);
  });

  test('AudioTrack subtitle prefers artist', () {
    const track = AudioTrack(
      id: 'content://song',
      title: 'Song B',
      uri: 'content://song',
      source: AudioSourceType.content,
      artist: 'Artist B',
    );

    expect(track.subtitle, 'Artist B');
  });
}
