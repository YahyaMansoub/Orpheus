// Downloads Jamendo tracks for local library use.

import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../models/audio_track.dart';
import '../models/jamendo_track.dart';

class DownloadService {
  Future<AudioTrack?> downloadTrack(JamendoTrack track) async {
    if (!track.canDownload || track.audioDownload == null) {
      return null;
    }

    final downloadUrl = track.audioDownload!.trim();
    if (downloadUrl.isEmpty) {
      return null;
    }

    final directory = await getApplicationDocumentsDirectory();
    final targetDir = Directory('${directory.path}/jamendo');
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    final fileName = _buildFileName(track, downloadUrl);
    final file = File('${targetDir.path}/$fileName');

    if (await file.exists()) {
      return AudioTrack.fromFile(name: fileName, path: file.path);
    }

    final response = await http.get(Uri.parse(downloadUrl));
    if (response.statusCode != 200) {
      return null;
    }

    await file.writeAsBytes(response.bodyBytes);
    return AudioTrack.fromFile(name: fileName, path: file.path);
  }

  String _buildFileName(JamendoTrack track, String url) {
    final rawName = '${track.artistName} - ${track.name}';
    final sanitized = _sanitizeFileName(rawName);
    final extension = _inferExtension(url);
    final base = sanitized.isEmpty ? track.id : sanitized;
    final shortened = base.length > 120 ? base.substring(0, 120) : base;
    return '$shortened$extension';
  }

  String _inferExtension(String url) {
    final uri = Uri.tryParse(url);
    final last = uri?.pathSegments.isNotEmpty == true
        ? uri!.pathSegments.last
        : '';
    final dotIndex = last.lastIndexOf('.');
    if (dotIndex > 0 && dotIndex < last.length - 1) {
      final ext = last.substring(dotIndex);
      if (ext.length <= 6) {
        return ext;
      }
    }
    return '.mp3';
  }

  String _sanitizeFileName(String input) {
    final sanitized = input
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return sanitized.replaceAll(RegExp(r'[.]$'), '');
  }
}
