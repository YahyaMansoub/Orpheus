import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:orpheus/controllers/settings_controller.dart';
import 'package:orpheus/screens/settings_screen.dart';
import 'package:orpheus/services/settings_service.dart';

void main() {
  testWidgets('Settings screen shows theme options', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final controller = SettingsController(SettingsService(prefs));
    await controller.loadSettings();

    await tester.pumpWidget(
      MaterialApp(home: SettingsScreen(settingsController: controller)),
    );

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('System default'), findsOneWidget);
    expect(find.text('Light mode'), findsOneWidget);
    expect(find.text('Dark mode'), findsOneWidget);
  });
}
