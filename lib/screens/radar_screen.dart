// Radar fallback screen. Real full-device scanning will be added later.

import 'package:flutter/material.dart';

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
  String? _error;
  List<AudioTrack> _tracks = [];
  final Set<String> _selectedIds = {};

  bool _isAlreadyAdded(AudioTrack track) {
    return widget.libraryController.tracks.any((item) => item.id == track.id);
  }

  Future<void> _pickTracks() async {
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

      final tracks = await widget.radarService.pickAudioTracks();
      if (!mounted) return;

      setState(() {
        _tracks = tracks;
        _selectedIds.clear();
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error = 'Unable to import audio files right now.';
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
      body: _buildBody(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _pickTracks,
        icon: const Icon(Icons.audio_file),
        label: const Text('Select audio'),
      ),
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

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return EmptyState(title: _error!, icon: Icons.error_outline);
    }

    if (_tracks.isEmpty) {
      return const EmptyState(
        title: 'Radar fallback mode',
        subtitle:
            'Full-device scanning is not enabled yet. Use Select audio to choose files manually.',
        icon: Icons.radar,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 120),
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
        );
      },
      separatorBuilder: (_, _) => const Divider(height: 1),
    );
  }
}
