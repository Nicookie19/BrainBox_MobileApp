// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:brainbox/main.dart';
import 'package:brainbox/presentation/screens/daily_challenge_screen.dart';
import 'package:brainbox/data/services/storage_service.dart';

void main() {
  testWidgets('BrainBox app launches without crashing', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
    await tester.pumpWidget(const BrainBoxApp());

    // Wait for async initialization to complete
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Verify app launches - either home screen or loading skeleton
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Daily challenge screen works', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
    
    // Directly test daily challenge screen
    await tester.pumpWidget(
      const MaterialApp(home: _DailyChallengeTestScreen()),
    );
    await tester.pumpAndSettle();

    // Verify daily challenge screen loads with first question
    expect(find.text('What does Array.map() return?'), findsOneWidget);

    // Answer all 5 questions correctly
    // Q1: What does Array.map() return? -> A new array
    await tester.tap(find.text('A new array'));
    await tester.pump();
    expect(find.text('Array.map() creates a new array with the results of calling a provided function on every element.'), findsOneWidget);
    await tester.tap(find.text('Next Question'));
    await tester.pumpAndSettle();

    // Q2: Which keyword creates a constant in JavaScript? -> const
    await tester.tap(find.text('const'));
    await tester.pump();
    await tester.tap(find.text('Next Question'));
    await tester.pumpAndSettle();

    // Q3: What is the result of 2 + "2" in JavaScript? -> 22
    await tester.tap(find.text('22'));
    await tester.pump();
    await tester.tap(find.text('Next Question'));
    await tester.pumpAndSettle();

    // Q4: What does the spread operator (...) do? -> Copies array elements
    await tester.tap(find.text('Copies array elements'));
    await tester.pump();
    await tester.tap(find.text('Next Question'));
    await tester.pumpAndSettle();

    // Q5: Which method removes the last element from an array? -> pop()
    await tester.tap(find.text('pop()'));
    await tester.pump();
    await tester.tap(find.text('Finish Challenge'));
    await tester.pumpAndSettle();

    // Verify completion screen
    expect(find.text('Challenge Complete!'), findsOneWidget);
    expect(find.text('+50 XP'), findsOneWidget);
  });

  testWidgets('Home screen renders without crash', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
    await tester.pumpWidget(const BrainBoxApp());
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Just verify the app renders something
    expect(find.byType(Scaffold), findsWidgets);
  });
}

// Test wrapper for daily challenge screen
class _DailyChallengeTestScreen extends StatelessWidget {
  const _DailyChallengeTestScreen();

  @override
  Widget build(BuildContext context) {
    return const DailyChallengeScreen();
  }
}