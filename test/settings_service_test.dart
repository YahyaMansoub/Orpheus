import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:orpheus/services/settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('SettingsService persists theme mode', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final service = SettingsService(prefs);

    await service.saveThemeMode(AppThemeMode.dark);

    final loaded = await service.loadThemeMode();
    expect(loaded, AppThemeMode.dark);
  });
}
