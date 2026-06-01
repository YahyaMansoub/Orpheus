// Shared list tile UI for audio tracks.

import 'package:flutter/material.dart';

import '../models/audio_track.dart';

class TrackTile extends StatelessWidget {
  final AudioTrack track;
  final bool isActive;
  final bool isMissing;
  final VoidCallback? onTap;
  final Widget? leading;

  const TrackTile({
    super.key,
    required this.track,
    this.isActive = false,
    this.isMissing = false,
    this.onTap,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final baseIcon = isMissing
        ? Icons.music_off
        : isActive
        ? Icons.equalizer
        : Icons.music_note;

    return ListTile(
      leading: leading ?? Icon(baseIcon),
      title: Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        track.subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: isMissing
          ? const Icon(Icons.warning_amber_rounded)
          : (isActive ? const Icon(Icons.play_arrow) : null),
      onTap: isMissing ? null : onTap,
    );
  }
}
