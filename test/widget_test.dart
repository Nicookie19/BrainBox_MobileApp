// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:brainbox/main.dart';
import 'package:brainbox/data/services/storage_service.dart';

void main() {
  testWidgets('BrainBox dashboard loads', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
    await tester.pumpWidget(const BrainBoxApp());

    expect(find.text('A little sharper\ntoday.'), findsOneWidget);
    expect(find.text('Your next 10 minutes'), findsOneWidget);

    await tester.ensureVisible(find.text('Daily challenge'));
    await tester.tap(find.text('Daily challenge'));
    await tester.pumpAndSettle();
    expect(find.text('What does Array.map() return?'), findsOneWidget);

    await tester.tap(find.text('A new array'));
    await tester.pump();
    expect(find.text('Correct — nice work!'), findsOneWidget);
    await tester.tap(find.text('Next question'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('const'));
    await tester.pump();
    await tester.tap(find.text('Next question'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('22'));
    await tester.pump();
    await tester.tap(find.text('Finish challenge'));
    await tester.pumpAndSettle();

    expect(find.text('Completed · 50 XP earned'), findsOneWidget);
  });
}
