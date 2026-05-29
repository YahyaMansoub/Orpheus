// Scans the device library and lets users import selected audio.

import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../app/app_routes.dart';
import '../controllers/library_controller.dart';
import '../models/audio_track.dart';
import '../services/permission_service.dart';
import '../services/radar_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/empty_state.dart';

class RadarScreen extends StatefulWidget {
  final LibraryController libraryController;
  final RadarService radarService;
  final PermissionService permissionService;

  const RadarScreen({
    super.key,
    required this.libraryController,
    required this.radarService,
    required this.permissionService,
  });

  @override
  State<RadarScreen> createState() => _RadarScreenState();
}

class _RadarScreenState extends State<RadarScreen> {
  bool _isLoading = false;
  bool _hasPermission = false;
  String? _error;
  List<AudioTrack> _tracks = [];
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final allowed = await widget.permissionService.ensureAudioPermission();
    if (!allowed) {
      setState(() {
        _hasPermission = false;
        _isLoading = false;
      });
      return;
    }

    try {
      final tracks = await widget.radarService.queryTracks();
      setState(() {
        _tracks = tracks;
        _hasPermission = true;
      });
    } catch (_) {
      setState(() {
        _error = 'Unable to scan your library right now.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _isAlreadyAdded(AudioTrack track) {
    return widget.libraryController.tracks.any((item) => item.id == track.id);
  }

  Future<void> _addSelected() async {
    final selected = _tracks
        .where((track) => _selectedIds.contains(track.id))
        .toList();

    await widget.libraryController.addTracks(selected);

    if (!mounted) {
      return;
    }

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
      bottomNavigationBar: _selectedIds.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton(
                  onPressed: _addSelected,
                  child: Text('Add ${_selectedIds.length} to library'),
                ),
              ),
            ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_hasPermission) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock, size: 48),
              const SizedBox(height: 12),
              Text(
                'Permission needed',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              const Text(
                'Allow access to scan your device library.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _load,
                child: const Text('Grant permission'),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return EmptyState(title: _error!, icon: Icons.error_outline);
    }

    if (_tracks.isEmpty) {
      return const EmptyState(
        title: 'No audio found.',
        subtitle: 'Radar did not find any compatible files.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: _tracks.length,
      itemBuilder: (context, index) {
        final track = _tracks[index];
        final alreadyAdded = _isAlreadyAdded(track);
        final selected = _selectedIds.contains(track.id);

        return CheckboxListTile(
          value: selected,
          onChanged: alreadyAdded
              ? null
              : (value) {
                  if (value == true) {
                    setState(() => _selectedIds.add(track.id));
                  } else {
                    setState(() => _selectedIds.remove(track.id));
                  }
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
          secondary: track.artworkId == null
              ? const Icon(Icons.audiotrack)
              : QueryArtworkWidget(
                  id: track.artworkId!,
                  type: ArtworkType.AUDIO,
                  artworkBorder: BorderRadius.circular(6),
                  artworkQuality: FilterQuality.low,
                  nullArtworkWidget: const Icon(Icons.audiotrack),
                ),
        );
      },
      separatorBuilder: (_, _) => const Divider(height: 1),
    );
  }
}
