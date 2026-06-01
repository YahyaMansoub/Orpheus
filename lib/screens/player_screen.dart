// Full-screen player with artwork, progress, and controls.

import 'package:flutter/material.dart';

import '../controllers/player_controller.dart';
import '../models/audio_track.dart';
import '../widgets/player_controls.dart';

class PlayerScreen extends StatelessWidget {
  final PlayerController playerController;

  const PlayerScreen({super.key, required this.playerController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Now Playing')),
      body: AnimatedBuilder(
        animation: playerController,
        builder: (context, _) {
          final track = playerController.currentTrack;
          if (track == null) {
            return const Center(child: Text('No track selected.'));
          }

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _Artwork(track: track),
                const SizedBox(height: 24),
                Text(
                  track.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (track.artist != null && track.artist!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    track.artist!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 24),
                _ProgressBar(playerController: playerController),
                const SizedBox(height: 24),
                PlayerControls(playerController: playerController),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Artwork extends StatelessWidget {
  final AudioTrack track;

  const _Artwork({required this.track});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.7;
    return _placeholder(size, context);
  }

  Widget _placeholder(double size, BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.album, size: 96),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final PlayerController playerController;

  const _ProgressBar({required this.playerController});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Duration>(
      valueListenable: playerController.position,
      builder: (context, position, _) {
        return ValueListenableBuilder<Duration>(
          valueListenable: playerController.duration,
          builder: (context, duration, _) {
            final maxMs = duration.inMilliseconds.toDouble();
            final valueMs = position.inMilliseconds.clamp(0, maxMs.toInt());

            return Column(
              children: [
                Slider(
                  min: 0,
                  max: maxMs > 0 ? maxMs : 1,
                  value: maxMs > 0 ? valueMs.toDouble() : 0,
                  onChanged: maxMs > 0
                      ? (value) => playerController.seek(
                          Duration(milliseconds: value.toInt()),
                        )
                      : null,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDuration(position)),
                    Text(_formatDuration(duration)),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
