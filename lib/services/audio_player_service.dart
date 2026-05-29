// Wraps just_audio with a small API for queue playback.

import 'package:just_audio/just_audio.dart';

import '../models/audio_track.dart';

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();

  AudioPlayer get player => _player;

  Future<void> setQueue(List<AudioTrack> tracks, {required int initialIndex}) {
    final sources = tracks
        .map((track) => AudioSource.uri(track.audioUri, tag: track))
        .toList();

    return _player.setAudioSource(
      // ignore: deprecated_member_use
      ConcatenatingAudioSource(children: sources),
      initialIndex: initialIndex,
    );
  }

  Future<void> play() => _player.play();

  Future<void> pause() => _player.pause();

  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> seekToNext() => _player.seekToNext();

  Future<void> seekToPrevious() => _player.seekToPrevious();

  void dispose() => _player.dispose();
}
