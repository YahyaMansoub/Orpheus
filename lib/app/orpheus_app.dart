// Wires up app-wide services, controllers, and navigation.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/library_controller.dart';
import '../controllers/playlist_controller.dart';
import '../controllers/player_controller.dart';
import '../controllers/settings_controller.dart';
import '../services/audio_library_service.dart';
import '../services/audio_player_service.dart';
import '../services/playlist_service.dart';
import '../services/permission_service.dart';
import '../services/radar_service.dart';
import '../services/settings_service.dart';
import 'app_routes.dart';

class OrpheusApp extends StatefulWidget {
  final SharedPreferences prefs;

  const OrpheusApp({super.key, required this.prefs});

  @override
  State<OrpheusApp> createState() => _OrpheusAppState();
}

class _OrpheusAppState extends State<OrpheusApp> {
  late final AudioLibraryService _libraryService;
  late final AudioPlayerService _playerService;
  late final LibraryController _libraryController;
  late final PlayerController _playerController;
  late final PlaylistService _playlistService;
  late final PlaylistController _playlistController;
  late final RadarService _radarService;
  late final PermissionService _permissionService;
  late final SettingsService _settingsService;
  late final SettingsController _settingsController;

  @override
  void initState() {
    super.initState();
    _libraryService = AudioLibraryService(widget.prefs);
    _playerService = AudioPlayerService();
    _libraryController = LibraryController(_libraryService)..loadLibrary();
    _playerController = PlayerController(_playerService);
    _playlistService = PlaylistService(widget.prefs);
    _playlistController = PlaylistController(_playlistService)..loadPlaylists();
    _radarService = RadarService();
    _permissionService = PermissionService();
    _settingsService = SettingsService(widget.prefs);
    _settingsController = SettingsController(_settingsService)..loadSettings();
  }

  @override
  void dispose() {
    _playerController.dispose();
    _libraryController.dispose();
    _playlistController.dispose();
    _settingsController.dispose();
    _playerService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _settingsController,
      builder: (context, _) {
        return MaterialApp(
          title: 'Orpheus',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          themeMode: _settingsController.materialThemeMode,
          initialRoute: AppRoutes.home,
          onGenerateRoute: (settings) => AppRoutes.onGenerateRoute(
            settings,
            libraryController: _libraryController,
            playerController: _playerController,
            playlistController: _playlistController,
            radarService: _radarService,
            permissionService: _permissionService,
            settingsController: _settingsController,
          ),
        );
      },
    );
  }
}
