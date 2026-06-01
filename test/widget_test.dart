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
    expect(find.text('Playlists'), findsOneWidget);
    expect(find.text('General Downloads'), findsOneWidget);
    expect(find.text('Radar'), findsOneWidget);
  });
}
