// Shared app drawer for quick section navigation.

import 'package:flutter/material.dart';

import '../app/app_routes.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

  void _navigate(BuildContext context, String route) {
    Navigator.of(context).pop();
    if (currentRoute == route) {
      return;
    }
    Navigator.of(context).pushNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.black87),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'Orpheus',
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            selected: currentRoute == AppRoutes.home,
            onTap: () => _navigate(context, AppRoutes.home),
          ),
          ListTile(
            leading: const Icon(Icons.radar),
            title: const Text('Radar'),
            selected: currentRoute == AppRoutes.radar,
            onTap: () => _navigate(context, AppRoutes.radar),
          ),
          ListTile(
            leading: const Icon(Icons.queue_music),
            title: const Text('Playlists'),
            selected: currentRoute == AppRoutes.playlists,
            onTap: () => _navigate(context, AppRoutes.playlists),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            selected: currentRoute == AppRoutes.settings,
            onTap: () => _navigate(context, AppRoutes.settings),
          ),
        ],
      ),
    );
  }
}
