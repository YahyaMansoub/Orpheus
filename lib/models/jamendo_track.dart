// Represents a Jamendo track payload used in Discover.

class JamendoTrack {
  final String id;
  final String name;
  final String artistName;
  final String? albumName;
  final String? image;
  final String audio;
  final String? audioDownload;
  final bool audioDownloadAllowed;
  final String? licenseCcurl;
  final int duration;

  const JamendoTrack({
    required this.id,
    required this.name,
    required this.artistName,
    required this.albumName,
    required this.image,
    required this.audio,
    required this.audioDownload,
    required this.audioDownloadAllowed,
    required this.licenseCcurl,
    required this.duration,
  });

  factory JamendoTrack.fromJson(Map<String, dynamic> json) {
    return JamendoTrack(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? 'Unknown title',
      artistName: json['artist_name'] as String? ?? 'Unknown artist',
      albumName: json['album_name'] as String?,
      image: json['image'] as String?,
      audio: json['audio'] as String? ?? '',
      audioDownload: json['audiodownload'] as String?,
      audioDownloadAllowed: (json['audiodownload_allowed'] as bool?) ?? false,
      licenseCcurl: json['license_ccurl'] as String?,
      duration: _parseDuration(json['duration']),
    );
  }

  static int _parseDuration(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  bool get canDownload {
    return audioDownloadAllowed && (audioDownload?.isNotEmpty ?? false);
  }
}
