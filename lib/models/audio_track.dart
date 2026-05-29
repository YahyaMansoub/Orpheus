// Defines the audio track model shared across the library and player.

import 'dart:convert';

enum AudioSourceType { file, content }

class AudioTrack {
  final String id;
  final String title;
  final String uri;
  final AudioSourceType source;
  final String? artist;
  final int? artworkId;

  const AudioTrack({
    required this.id,
    required this.title,
    required this.uri,
    required this.source,
    this.artist,
    this.artworkId,
  });

  factory AudioTrack.fromFile({required String name, required String path}) {
    final uri = Uri.file(path).toString();
    return AudioTrack(
      id: uri,
      title: name,
      uri: uri,
      source: AudioSourceType.file,
    );
  }

  factory AudioTrack.fromContent({
    required String title,
    required String uri,
    String? artist,
    int? artworkId,
  }) {
    return AudioTrack(
      id: uri,
      title: title,
      uri: uri,
      source: AudioSourceType.content,
      artist: artist,
      artworkId: artworkId,
    );
  }

  factory AudioTrack.fromJson(Map<String, dynamic> json) {
    final sourceValue = json['source'] as String?;
    final source = AudioSourceType.values.firstWhere(
      (value) => value.name == sourceValue,
      orElse: () => AudioSourceType.file,
    );

    return AudioTrack(
      id: json['id'] as String,
      title: json['title'] as String,
      uri: json['uri'] as String,
      source: source,
      artist: json['artist'] as String?,
      artworkId: json['artworkId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'uri': uri,
      'source': source.name,
      'artist': artist,
      'artworkId': artworkId,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  Uri get audioUri => Uri.parse(uri);

  bool get isFileSource => source == AudioSourceType.file;

  String get subtitle {
    if (artist != null && artist!.trim().isNotEmpty) {
      return artist!;
    }

    if (isFileSource) {
      return audioUri.toFilePath();
    }

    return 'Unknown artist';
  }
}
