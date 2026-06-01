// Coordinates persisted app settings and change notifications.

import 'package:flutter/material.dart';

import '../services/settings_service.dart';

class SettingsController extends ChangeNotifier {
  final SettingsService _service;
  AppThemeMode _themeMode = AppThemeMode.system;

  SettingsController(this._service);

  AppThemeMode get themeMode => _themeMode;

  ThemeMode get materialThemeMode {
    switch (_themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  Future<void> loadSettings() async {
    _themeMode = await _service.loadThemeMode();
    notifyListeners();
  }

  Future<void> updateThemeMode(AppThemeMode mode) async {
    if (mode == _themeMode) {
      return;
    }

    _themeMode = mode;
    notifyListeners();
    await _service.saveThemeMode(mode);
  }
}
