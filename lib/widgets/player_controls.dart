// Reusable playback controls for the full player screen.

import 'package:flutter/material.dart';

import '../controllers/player_controller.dart';

class PlayerControls extends StatelessWidget {
  final PlayerController playerController;

  const PlayerControls({super.key, required this.playerController});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          iconSize: 36,
          onPressed: playerController.skipPrevious,
          icon: const Icon(Icons.skip_previous),
        ),
        const SizedBox(width: 12),
        ValueListenableBuilder<bool>(
          valueListenable: playerController.isPlaying,
          builder: (context, isPlaying, _) {
            return IconButton(
              iconSize: 52,
              onPressed: playerController.togglePlayPause,
              icon: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle),
            );
          },
        ),
        const SizedBox(width: 12),
        IconButton(
          iconSize: 36,
          onPressed: playerController.skipNext,
          icon: const Icon(Icons.skip_next),
        ),
      ],
    );
  }
}
