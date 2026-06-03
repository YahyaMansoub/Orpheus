import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:orpheus/app/orpheus_app.dart';

void main() {
  testWidgets('Orpheus home screen renders', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(OrpheusApp(prefs: prefs));
    await tester.pumpAndSettle();

    expect(find.text('Orpheus'), findsOneWidget);
    expect(find.text('Radar'), findsOneWidget);
    expect(find.text('Discover'), findsOneWidget);
    expect(find.text('Playlists'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('App drawer includes Discover', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(OrpheusApp(prefs: prefs));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();

    expect(
      find.descendant(of: find.byType(Drawer), matching: find.text('Discover')),
      findsOneWidget,
    );
  });
}
