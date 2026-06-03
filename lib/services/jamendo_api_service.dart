// Handles Jamendo API calls for Discover.

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/jamendo_track.dart';

class JamendoApiService {
  static const _baseUrl = 'https://api.jamendo.com/v3.0';

  Future<List<JamendoTrack>> searchTracks({
    required String query,
    required String clientId,
  }) async {
    final uri = Uri.parse('$_baseUrl/tracks').replace(
      queryParameters: {
        'client_id': clientId,
        'format': 'json',
        'limit': '50',
        'namesearch': query,
        'include': 'musicinfo',
        'order': 'popularity_week',
        'audioformat': 'mp32',
        'search': query,
        'track_id': '',
        'fields':
            'id,name,artist_name,album_name,image,audio,audiodownload,audiodownload_allowed,license_ccurl,duration',
      },
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Jamendo request failed: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final results = decoded['results'] as List<dynamic>? ?? [];

    return results
        .whereType<Map<String, dynamic>>()
        .map(JamendoTrack.fromJson)
        .where((track) => track.audio.isNotEmpty)
        .toList();
  }
}
