import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

import '../models/audio_track.dart';

class RadarService {
  static const _channel = MethodChannel('orpheus/radar');

  Future<List<AudioTrack>> scanDeviceAudio() async {
    final result = await _channel.invokeMethod<List<dynamic>>('scanAudio');

    if (result == null) {
      return [];
    }

    return result
        .whereType<Map<dynamic, dynamic>>()
        .map(
          (item) => AudioTrack(
            id: item['id'] as String,
            title: (item['title'] as String?)?.trim().isNotEmpty == true
                ? item['title'] as String
                : 'Unknown title',
            uri: item['uri'] as String,
            source: AudioSourceType.content,
            artist: item['artist'] as String?,
            artworkId: item['artworkId'] as int?,
          ),
        )
        .toList();
  }

  Future<List<AudioTrack>> pickAudioTracks() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'm4a', 'aac', 'flac', 'ogg'],
      allowMultiple: true,
    );

    if (result == null) {
      return [];
    }

    return result.files
        .where((file) => file.path != null)
        .map((file) => AudioTrack.fromFile(name: file.name, path: file.path!))
        .toList();
  }
}
