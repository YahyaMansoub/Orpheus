import 'package:flutter/material.dart';

import '../app/app_routes.dart';
import '../controllers/library_controller.dart';
import '../controllers/player_controller.dart';
import '../models/audio_track.dart';
import '../services/permission_service.dart';
import '../services/radar_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/empty_state.dart';
import '../widgets/mini_player.dart';
import '../widgets/track_tile.dart';

class RadarScreen extends StatefulWidget {
  final LibraryController libraryController;
  final PlayerController playerController;
  final RadarService radarService;
  final PermissionService permissionService;

  const RadarScreen({
    super.key,
    required this.libraryController,
    required this.playerController,
    required this.radarService,
    required this.permissionService,
  });

  @override
  State<RadarScreen> createState() => _RadarScreenState();
}

class _RadarScreenState extends State<RadarScreen> {
  bool _isLoading = false;
  String? _error;
  List<AudioTrack> _tracks = [];
  final Set<String> _selectedIds = {};

  bool _isAlreadyAdded(AudioTrack track) {
    return widget.libraryController.tracks.any((item) => item.id == track.id);
  }

  Future<void> _scanDevice() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final allowed = await widget.permissionService.ensureAudioPermission();
      if (!mounted) return;

      if (!allowed) {
        setState(() {
          _error = 'Audio permission was not granted.';
        });
        return;
      }

      final tracks = await widget.radarService.scanDeviceAudio();
      if (!mounted) return;

      setState(() {
        _tracks = tracks;
        _selectedIds.clear();
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error = 'Unable to scan audio files.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectManually() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final tracks = await widget.radarService.pickAudioTracks();
      if (!mounted) return;

      setState(() {
        _tracks = tracks;
        _selectedIds.clear();
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error = 'Unable to select audio files.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addSelected() async {
    final selected = _tracks
        .where((track) => _selectedIds.contains(track.id))
        .where((track) => !_isAlreadyAdded(track))
        .toList();

    await widget.libraryController.addTracks(selected);
    if (!mounted) return;

    setState(() {
      _selectedIds.clear();
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Added ${selected.length} tracks.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Radar')),
      drawer: const AppDrawer(currentRoute: AppRoutes.radar),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'scan-device',
            onPressed: _isLoading ? null : _scanDevice,
            icon: const Icon(Icons.radar),
            label: const Text('Scan device'),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'select-audio',
            onPressed: _isLoading ? null : _selectManually,
            icon: const Icon(Icons.audio_file),
            label: const Text('Select audio'),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return EmptyState(title: _error!, icon: Icons.error_outline);
    }

    return AnimatedBuilder(
      animation: widget.libraryController,
      builder: (context, _) {
        final libraryTracks = widget.libraryController.tracks;
        final hasLibrary = libraryTracks.isNotEmpty;
        final hasResults = _tracks.isNotEmpty;
        final isLibraryLoading = widget.libraryController.isLoading;

        if (!hasLibrary && !hasResults) {
          if (_isLoading || isLibraryLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return const EmptyState(
            title: 'Radar',
            subtitle:
                'Scan your device for audio files or select files manually.',
            icon: Icons.radar,
          );
        }

        final items = <Widget>[
          if (_isLoading || isLibraryLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: LinearProgressIndicator(),
            ),
        ];

        if (hasLibrary) {
          items.add(_SectionHeader(title: 'Library'));
          final queue = widget.libraryController.playableTracks();
          final currentTrack = widget.playerController.currentTrack;

          for (final track in libraryTracks) {
            final isMissing = widget.libraryController.isMissing(track);
            items.add(
              TrackTile(
                track: track,
                isActive: track.id == currentTrack?.id,
                isMissing: isMissing,
                onTap: isMissing
                    ? null
                    : () => widget.playerController.playTrack(track, queue),
              ),
            );
            items.add(const Divider(height: 1));
          }
        }

        if (hasResults) {
          items.add(_SectionHeader(title: 'Radar results'));
          for (final track in _tracks) {
            final alreadyAdded = _isAlreadyAdded(track);
            final selected = _selectedIds.contains(track.id);

            items.add(
              CheckboxListTile(
                value: selected,
                onChanged: alreadyAdded
                    ? null
                    : (value) {
                        setState(() {
                          if (value == true) {
                            _selectedIds.add(track.id);
                          } else {
                            _selectedIds.remove(track.id);
                          }
                        });
                      },
                title: Text(
                  track.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  alreadyAdded ? 'Already in library' : track.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                secondary: const Icon(Icons.audiotrack),
              ),
            );
            items.add(const Divider(height: 1));
          }
        }

        return ListView(
          padding: const EdgeInsets.only(bottom: 180),
          children: items,
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return AnimatedBuilder(
      animation: widget.playerController,
      builder: (context, _) {
        final hasSelection = _selectedIds.isNotEmpty;
        final hasTrack = widget.playerController.hasTrack;

        if (!hasSelection && !hasTrack) {
          return const SizedBox.shrink();
        }

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasSelection)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: FilledButton(
                    onPressed: _addSelected,
                    child: Text('Add ${_selectedIds.length} to library'),
                  ),
                ),
              if (hasTrack)
                MiniPlayer(
                  playerController: widget.playerController,
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.player),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(title, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}
