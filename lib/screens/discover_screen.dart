// Jamendo-powered discovery screen.

import 'package:flutter/material.dart';

import '../app/app_routes.dart';
import '../controllers/discover_controller.dart';
import '../controllers/player_controller.dart';
import '../models/audio_track.dart';
import '../models/jamendo_track.dart';
import '../widgets/app_drawer.dart';
import '../widgets/empty_state.dart';
import '../widgets/mini_player.dart';

class DiscoverScreen extends StatefulWidget {
  final DiscoverController discoverController;
  final PlayerController playerController;

  const DiscoverScreen({
    super.key,
    required this.discoverController,
    required this.playerController,
  });

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    await widget.discoverController.search(_searchController.text);
  }

  Future<void> _play(JamendoTrack track) async {
    final queue = widget.discoverController.results
        .map(_toAudioTrack)
        .where((item) => item.uri.isNotEmpty)
        .toList();

    final audioTrack = _toAudioTrack(track);
    if (audioTrack.uri.isEmpty) {
      return;
    }

    await widget.playerController.playTrack(audioTrack, queue);
  }

  AudioTrack _toAudioTrack(JamendoTrack track) {
    return AudioTrack.fromContent(
      title: track.name,
      uri: track.audio,
      artist: track.artistName,
    );
  }

  Future<void> _download(JamendoTrack track) async {
    final saved = await widget.discoverController.downloadTrack(track);
    if (!mounted) return;

    if (saved == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Download failed.')));
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Saved to library.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover')),
      drawer: const AppDrawer(currentRoute: AppRoutes.discover),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _search(),
                    decoration: const InputDecoration(
                      labelText: 'Search Jamendo',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(onPressed: _search, child: const Text('Search')),
              ],
            ),
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: widget.discoverController,
              builder: (context, _) {
                if (widget.discoverController.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final error = widget.discoverController.error;
                if (error != null) {
                  return EmptyState(title: error, icon: Icons.error_outline);
                }

                final results = widget.discoverController.results;
                if (results.isEmpty) {
                  return const EmptyState(
                    title: 'Discover',
                    subtitle: 'Search Jamendo for free music previews.',
                    icon: Icons.explore,
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: 140),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final track = results[index];
                    return _JamendoTrackTile(
                      track: track,
                      onPlay: () => _play(track),
                      onDownload: widget.discoverController.canDownload(track)
                          ? () => _download(track)
                          : null,
                    );
                  },
                  separatorBuilder: (_, _) => const Divider(height: 1),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: widget.playerController,
        builder: (context, _) {
          if (!widget.playerController.hasTrack) {
            return const SizedBox.shrink();
          }
          return MiniPlayer(
            playerController: widget.playerController,
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.player),
          );
        },
      ),
    );
  }
}

class _JamendoTrackTile extends StatelessWidget {
  final JamendoTrack track;
  final VoidCallback onPlay;
  final VoidCallback? onDownload;

  const _JamendoTrackTile({
    required this.track,
    required this.onPlay,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _CoverImage(url: track.image),
      title: Text(track.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(track.artistName, maxLines: 1, overflow: TextOverflow.ellipsis),
          if (track.albumName != null && track.albumName!.isNotEmpty)
            Text(
              track.albumName!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          if (track.licenseCcurl != null && track.licenseCcurl!.isNotEmpty)
            Text(
              'License: ${track.licenseCcurl}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          const SizedBox(height: 6),
          Row(
            children: [
              FilledButton.icon(
                onPressed: onPlay,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Play'),
              ),
              const SizedBox(width: 8),
              if (onDownload != null)
                OutlinedButton.icon(
                  onPressed: onDownload,
                  icon: const Icon(Icons.download),
                  label: const Text('Download'),
                ),
            ],
          ),
        ],
      ),
      isThreeLine: true,
    );
  }
}

class _CoverImage extends StatelessWidget {
  final String? url;

  const _CoverImage({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return const CircleAvatar(child: Icon(Icons.album));
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url!,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const CircleAvatar(child: Icon(Icons.album)),
      ),
    );
  }
}
