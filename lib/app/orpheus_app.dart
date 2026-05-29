// Wires up app-wide services, controllers, and navigation.

import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/library_controller.dart';
import '../controllers/player_controller.dart';
import '../services/audio_library_service.dart';
import '../services/audio_player_service.dart';
import '../services/permission_service.dart';
import '../services/radar_service.dart';
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
  late final OnAudioQuery _audioQuery;
  late final RadarService _radarService;
  late final PermissionService _permissionService;

  @override
  void initState() {
    super.initState();
    _libraryService = AudioLibraryService(widget.prefs);
    _playerService = AudioPlayerService();
    _libraryController = LibraryController(_libraryService)..loadLibrary();
    _playerController = PlayerController(_playerService);
    _audioQuery = OnAudioQuery();
    _radarService = RadarService(_audioQuery);
    _permissionService = PermissionService(_audioQuery);
  }

  @override
  void dispose() {
    _playerController.dispose();
    _libraryController.dispose();
    _playerService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Orpheus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.home,
      onGenerateRoute: (settings) => AppRoutes.onGenerateRoute(
        settings,
        libraryController: _libraryController,
        playerController: _playerController,
        radarService: _radarService,
        permissionService: _permissionService,
      ),
    );
  }
}
