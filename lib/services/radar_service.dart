// Temporary Radar fallback: imports audio through file_picker until native scanning is added.

import 'package:file_picker/file_picker.dart';

import '../models/audio_track.dart';

class RadarService {
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
