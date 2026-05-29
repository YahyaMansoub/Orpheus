import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  runApp(const OrpheusApp());
}

class OrpheusApp extends StatelessWidget {
  const OrpheusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Orpheus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class Song {
  final String name;
  final String path;

  const Song({required this.name, required this.path});
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AudioPlayer _player = AudioPlayer();

  final List<Song> _songs = [];
  Song? _currentSong;
  bool _isPlaying = false;

  Future<void> _pickSongs() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3'],
      allowMultiple: true,
    );

    if (result == null) {
      return;
    }

    final pickedSongs = result.files
        .where((file) => file.path != null)
        .map((file) => Song(name: file.name, path: file.path!))
        .toList();

    setState(() {
      _songs.addAll(pickedSongs);
    });
  }

  Future<void> _playSong(Song song) async {
    try {
      await _player.setFilePath(song.path);
      await _player.play();

      setState(() {
        _currentSong = song;
        _isPlaying = true;
      });
    } catch (e) {
      debugPrint("Error playing song ${song.path}: $e");
    }
  }

  Future<void> _togglePlayPause() async {
    if (_currentSong == null) {
      return;
    }

    if (_player.playing) {
      await _player.pause();

      setState(() {
        _isPlaying = false;
      });
    } else {
      await _player.play();

      setState(() {
        _isPlaying = true;
      });
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentSong = _currentSong;

    return Scaffold(
      appBar: AppBar(title: const Text('Orpheus')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.icon(
              onPressed: _pickSongs,
              icon: const Icon(Icons.library_music),
              label: const Text('Import MP3 files'),
            ),
          ),
          Expanded(
            child: _songs.isEmpty
                ? const Center(child: Text('No songs imported yet.'))
                : ListView.builder(
                    itemCount: _songs.length,
                    itemBuilder: (context, index) {
                      final song = _songs[index];
                      final isCurrent = song.path == currentSong?.path;

                      return ListTile(
                        leading: Icon(
                          isCurrent ? Icons.equalizer : Icons.music_note,
                        ),
                        title: Text(song.name),
                        subtitle: Text(song.path),
                        onTap: () => _playSong(song),
                      );
                    },
                  ),
          ),
          if (currentSong != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      currentSong.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: _togglePlayPause,
                    icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
