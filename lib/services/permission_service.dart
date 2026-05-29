// Centralizes audio permission requests for Radar.

import 'package:on_audio_query/on_audio_query.dart';

class PermissionService {
  final OnAudioQuery _audioQuery;

  PermissionService(this._audioQuery);

  Future<bool> ensureAudioPermission() async {
    final hasPermission = await _audioQuery.permissionsStatus();
    if (hasPermission) {
      return true;
    }

    return _audioQuery.permissionsRequest();
  }
}
