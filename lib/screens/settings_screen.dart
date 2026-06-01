// App settings screen with theme selection.

import 'package:flutter/material.dart';

import '../app/app_routes.dart';
import '../controllers/settings_controller.dart';
import '../services/settings_service.dart';
import '../widgets/app_drawer.dart';

class SettingsScreen extends StatelessWidget {
  final SettingsController settingsController;

  const SettingsScreen({super.key, required this.settingsController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      drawer: const AppDrawer(currentRoute: AppRoutes.settings),
      body: AnimatedBuilder(
        animation: settingsController,
        builder: (context, _) {
          return RadioGroup<AppThemeMode>(
            groupValue: settingsController.themeMode,
            onChanged: (mode) {
              if (mode != null) {
                settingsController.updateThemeMode(mode);
              }
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Theme', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                const _ThemeOptionTile(
                  title: 'System default',
                  value: AppThemeMode.system,
                ),
                const _ThemeOptionTile(
                  title: 'Light mode',
                  value: AppThemeMode.light,
                ),
                const _ThemeOptionTile(
                  title: 'Dark mode',
                  value: AppThemeMode.dark,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ThemeOptionTile extends StatelessWidget {
  final String title;
  final AppThemeMode value;

  const _ThemeOptionTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return RadioListTile<AppThemeMode>(title: Text(title), value: value);
  }
}
