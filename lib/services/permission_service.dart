import 'package:flutter/services.dart';

class PermissionService {
  static const _channel = MethodChannel('orpheus/radar');

  Future<bool> hasAudioPermission() async {
    final result = await _channel.invokeMethod<bool>('hasAudioPermission');
    return result ?? false;
  }

  Future<bool> ensureAudioPermission() async {
    final hasPermission = await hasAudioPermission();
    if (hasPermission) return true;

    final granted = await _channel.invokeMethod<bool>('requestAudioPermission');
    return granted ?? false;
  }
}
