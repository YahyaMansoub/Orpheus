// Defines named routes and transitions for the app.

import 'package:flutter/material.dart';

import '../controllers/library_controller.dart';
import '../controllers/playlist_controller.dart';
import '../controllers/player_controller.dart';
import '../screens/general_downloads_screen.dart';
import '../screens/home_screen.dart';
import '../screens/player_screen.dart';
import '../screens/playlists_screen.dart';
import '../screens/radar_screen.dart';
import '../services/permission_service.dart';
import '../services/radar_service.dart';

class AppRoutes {
  static const home = '/';
  static const generalDownloads = '/downloads';
  static const radar = '/radar';
  static const playlists = '/playlists';
  static const player = '/player';

  static Route<dynamic> onGenerateRoute(
    RouteSettings settings, {
    required LibraryController libraryController,
    required PlayerController playerController,
    required PlaylistController playlistController,
    required RadarService radarService,
    required PermissionService permissionService,
  }) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => HomeScreen(playerController: playerController),
        );
      case generalDownloads:
        return MaterialPageRoute(
          builder: (_) => GeneralDownloadsScreen(
            libraryController: libraryController,
            playerController: playerController,
          ),
        );
      case radar:
        return MaterialPageRoute(
          builder: (_) => RadarScreen(
            libraryController: libraryController,
            radarService: radarService,
            permissionService: permissionService,
          ),
        );
      case playlists:
        return MaterialPageRoute(
          builder: (_) => PlaylistsScreen(
            playlistController: playlistController,
            libraryController: libraryController,
            playerController: playerController,
          ),
        );
      case player:
        return PageRouteBuilder(
          pageBuilder: (_, _, _) =>
              PlayerScreen(playerController: playerController),
          transitionsBuilder: (context, animation, secondary, child) {
            const begin = Offset(0, 1);
            const end = Offset.zero;
            final tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: Curves.easeOutCubic));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
      default:
        return MaterialPageRoute(
          builder: (_) => HomeScreen(playerController: playerController),
        );
    }
  }
}
