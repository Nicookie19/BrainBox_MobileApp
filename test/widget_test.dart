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
import 'package:brainbox/data/repositories/daily_challenge_repository.dart';
import 'package:brainbox/data/services/storage_service.dart';

// Test wrapper for daily challenge screen with fixed date
class _DailyChallengeTestScreen extends StatelessWidget {
  final DateTime fixedDate;
  const _DailyChallengeTestScreen({required this.fixedDate});

  @override
  Widget build(BuildContext context) {
    return DailyChallengeScreen(fixedDate: fixedDate);
  }
}

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

  testWidgets('Daily challenge screen works with fixed seed', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
    
    // Use a fixed date for deterministic testing
    final fixedDate = DateTime(2024, 1, 15);
    
    // Get the questions for this fixed date
    final questions = DailyChallengeRepository.getDailyQuestions(fixedDate);
    expect(questions.length, 5);
    
    // Directly test daily challenge screen with fixed date
    await tester.pumpWidget(
      MaterialApp(home: _DailyChallengeTestScreen(fixedDate: fixedDate)),
    );
    await tester.pumpAndSettle();

    // Verify daily challenge screen loads with first question from fixed date
    final firstQuestion = DailyChallengeRepository.getDailyQuestions(fixedDate).first.text;
    expect(find.text(firstQuestion), findsOneWidget);

    // Answer all 5 questions correctly
    for (int i = 0; i < 5; i++) {
      final question = DailyChallengeRepository.getDailyQuestions(fixedDate)[i];
      final correctAnswer = question.options[question.answer];
      
      await tester.tap(find.text(correctAnswer));
      await tester.pump();
      expect(find.text(question.explanation), findsOneWidget);
      
      if (i < 4) {
        await tester.tap(find.text('Next Question'));
        await tester.pumpAndSettle();
      } else {
        await tester.tap(find.text('Finish Challenge'));
        await tester.pumpAndSettle();
      }
    }

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