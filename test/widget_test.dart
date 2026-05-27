import 'package:flutter_test/flutter_test.dart';

import 'package:orpheus/main.dart';

void main() {
  testWidgets('Orpheus home screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const OrpheusApp());

    expect(find.text('Orpheus'), findsOneWidget);
    expect(find.text('Import MP3 files'), findsOneWidget);
    expect(find.text('No songs imported yet.'), findsOneWidget);
  });
}
