// Queries the device library for Radar scan results.

import 'package:on_audio_query/on_audio_query.dart';

import '../models/audio_track.dart';

class RadarService {
  final OnAudioQuery _audioQuery;

  RadarService(this._audioQuery);

  Future<List<AudioTrack>> queryTracks() async {
    final songs = await _audioQuery.querySongs(
      sortType: SongSortType.TITLE,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );

    return songs
        .where((song) => song.uri != null)
        .map(
          (song) => AudioTrack.fromContent(
            title: song.title,
            uri: song.uri!,
            artist: song.artist,
            artworkId: song.id,
          ),
        )
        .toList();
  }
}
