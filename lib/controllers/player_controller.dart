// Manages playback state and the active queue.

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/audio_track.dart';
import '../services/audio_player_service.dart';

class PlayerController extends ChangeNotifier {
  final AudioPlayerService _playerService;

  List<AudioTrack> _queue = [];
  AudioTrack? _currentTrack;

  final ValueNotifier<bool> isPlaying = ValueNotifier(false);
  final ValueNotifier<Duration> position = ValueNotifier(Duration.zero);
  final ValueNotifier<Duration> duration = ValueNotifier(Duration.zero);

  late final StreamSubscription<bool> _playingSubscription;
  late final StreamSubscription<Duration> _positionSubscription;
  late final StreamSubscription<Duration?> _durationSubscription;
  late final StreamSubscription<int?> _indexSubscription;

  PlayerController(this._playerService) {
    _playingSubscription = _playerService.player.playingStream.listen(
      (playing) => isPlaying.value = playing,
    );

    _positionSubscription = _playerService.player.positionStream.listen(
      (value) => position.value = value,
    );

    _durationSubscription = _playerService.player.durationStream.listen(
      (value) => duration.value = value ?? Duration.zero,
    );

    _indexSubscription = _playerService.player.currentIndexStream.listen((
      index,
    ) {
      if (index == null || index < 0 || index >= _queue.length) {
        return;
      }

      _currentTrack = _queue[index];
      notifyListeners();
    });
  }

  AudioTrack? get currentTrack => _currentTrack;

  List<AudioTrack> get queue => List.unmodifiable(_queue);

  bool get hasTrack => _currentTrack != null;

  Future<void> playTrack(AudioTrack track, List<AudioTrack> queue) async {
    if (queue.isEmpty) {
      return;
    }

    final index = queue.indexWhere((item) => item.id == track.id);
    if (index < 0) {
      return;
    }

    _queue = queue;
    await _playerService.setQueue(queue, initialIndex: index);
    await _playerService.play();
    _currentTrack = queue[index];
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    if (_playerService.player.playing) {
      await _playerService.pause();
    } else {
      await _playerService.play();
    }
  }

  Future<void> seek(Duration target) => _playerService.seek(target);

  Future<void> skipNext() async {
    if (_queue.length < 2) {
      return;
    }

    if (_playerService.player.hasNext) {
      await _playerService.seekToNext();
    }
  }

  Future<void> skipPrevious() async {
    if (_queue.length < 2) {
      return;
    }

    if (_playerService.player.hasPrevious) {
      await _playerService.seekToPrevious();
    } else {
      await _playerService.seek(Duration.zero);
    }
  }

  @override
  void dispose() {
    _playingSubscription.cancel();
    _positionSubscription.cancel();
    _durationSubscription.cancel();
    _indexSubscription.cancel();
    isPlaying.dispose();
    position.dispose();
    duration.dispose();
    super.dispose();
  }
}
