// Handles persistence for app settings.

import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { system, light, dark }

extension AppThemeModeStorage on AppThemeMode {
  String get storageValue {
    switch (this) {
      case AppThemeMode.system:
        return 'system';
      case AppThemeMode.light:
        return 'light';
      case AppThemeMode.dark:
        return 'dark';
    }
  }
}

AppThemeMode appThemeModeFromStorage(String? value) {
  switch (value) {
    case 'light':
      return AppThemeMode.light;
    case 'dark':
      return AppThemeMode.dark;
    case 'system':
    default:
      return AppThemeMode.system;
  }
}

class SettingsService {
  static const _themeKey = 'orpheus_theme_mode';

  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  Future<AppThemeMode> loadThemeMode() async {
    final raw = _prefs.getString(_themeKey);
    return appThemeModeFromStorage(raw);
  }

  Future<void> saveThemeMode(AppThemeMode mode) async {
    await _prefs.setString(_themeKey, mode.storageValue);
  }
}
