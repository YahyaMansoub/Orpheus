// Defines named routes and transitions for the app.

import 'package:flutter/material.dart';

import '../controllers/discover_controller.dart';
import '../controllers/library_controller.dart';
import '../controllers/playlist_controller.dart';
import '../controllers/player_controller.dart';
import '../screens/home_screen.dart';
import '../screens/discover_screen.dart';
import '../screens/player_screen.dart';
import '../screens/playlists_screen.dart';
import '../screens/radar_screen.dart';
import '../screens/settings_screen.dart';
import '../services/permission_service.dart';
import '../services/radar_service.dart';
import '../controllers/settings_controller.dart';

class AppRoutes {
  static const home = '/';
  static const radar = '/radar';
  static const discover = '/discover';
  static const playlists = '/playlists';
  static const player = '/player';
  static const settings = '/settings';

  static Route<dynamic> onGenerateRoute(
    RouteSettings routeSettings, {
    required DiscoverController discoverController,
    required LibraryController libraryController,
    required PlayerController playerController,
    required PlaylistController playlistController,
    required RadarService radarService,
    required PermissionService permissionService,
    required SettingsController settingsController,
  }) {
    switch (routeSettings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => HomeScreen(playerController: playerController),
        );
      case radar:
        return MaterialPageRoute(
          builder: (_) => RadarScreen(
            libraryController: libraryController,
            playerController: playerController,
            radarService: radarService,
            permissionService: permissionService,
          ),
        );
      case discover:
        return MaterialPageRoute(
          builder: (_) => DiscoverScreen(
            discoverController: discoverController,
            playerController: playerController,
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
      case settings:
        return MaterialPageRoute(
          builder: (_) =>
              SettingsScreen(settingsController: settingsController),
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
