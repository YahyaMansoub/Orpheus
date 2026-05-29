// Compact player widget for the bottom of list screens.

import 'package:flutter/material.dart';

import '../controllers/player_controller.dart';

class MiniPlayer extends StatelessWidget {
  final PlayerController playerController;
  final VoidCallback onTap;

  const MiniPlayer({
    super.key,
    required this.playerController,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final track = playerController.currentTrack;
    if (track == null) {
      return const SizedBox.shrink();
    }

    return Material(
      elevation: 6,
      color: Theme.of(context).colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      track.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: playerController.isPlaying,
                    builder: (context, isPlaying, _) {
                      return IconButton(
                        icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                        onPressed: playerController.togglePlayPause,
                      );
                    },
                  ),
                ],
              ),
              ValueListenableBuilder<Duration>(
                valueListenable: playerController.position,
                builder: (context, position, _) {
                  return ValueListenableBuilder<Duration>(
                    valueListenable: playerController.duration,
                    builder: (context, duration, _) {
                      final totalMs = duration.inMilliseconds;
                      final positionMs = position.inMilliseconds;
                      final value = totalMs > 0
                          ? (positionMs / totalMs).clamp(0.0, 1.0)
                          : 0.0;
                      return LinearProgressIndicator(value: value);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
