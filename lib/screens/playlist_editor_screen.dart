import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../controllers/playlist_controller.dart';
import '../models/playlist.dart';

class PlaylistEditorScreen extends StatefulWidget {
  final PlaylistController playlistController;
  final Playlist? playlist;

  const PlaylistEditorScreen({
    super.key,
    required this.playlistController,
    this.playlist,
  });

  @override
  State<PlaylistEditorScreen> createState() => _PlaylistEditorScreenState();
}

class _PlaylistEditorScreenState extends State<PlaylistEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  String? _imagePath;

  bool get _isEditing => widget.playlist != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.playlist?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.playlist?.description ?? '',
    );
    _imagePath = widget.playlist?.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'webp'],
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final picked = result.files.first;
    if (picked.path == null) {
      return;
    }

    setState(() {
      _imagePath = picked.path;
    });
  }

  void _removeImage() {
    setState(() {
      _imagePath = null;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    if (_isEditing) {
      final updated = widget.playlist!.copyWith(
        name: name,
        description: description,
        imagePath: _imagePath,
      );
      await widget.playlistController.updatePlaylist(updated);
    } else {
      await widget.playlistController.createPlaylist(
        name: name,
        description: description,
        imagePath: _imagePath,
      );
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Playlist' : 'New Playlist'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _ImagePickerTile(
              imagePath: _imagePath,
              onPick: _pickImage,
              onRemove: _imagePath == null ? null : _removeImage,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Playlist name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Name is required.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: const Text('Save playlist')),
          ],
        ),
      ),
    );
  }
}

class _ImagePickerTile extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onPick;
  final VoidCallback? onRemove;

  const _ImagePickerTile({
    required this.imagePath,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final path = imagePath;

    return Row(
      children: [
        _PreviewBox(imagePath: path),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                path == null || path.isEmpty
                    ? 'No image selected.'
                    : 'Image selected',
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: onPick,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Choose image'),
                  ),
                  if (onRemove != null)
                    TextButton.icon(
                      onPressed: onRemove,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Remove'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PreviewBox extends StatelessWidget {
  final String? imagePath;

  const _PreviewBox({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final size = 88.0;
    final path = imagePath;

    if (path != null && path.isNotEmpty) {
      final file = File(path);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(file, width: size, height: size, fit: BoxFit.cover),
        );
      }
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.image, size: 36),
    );
  }
}
