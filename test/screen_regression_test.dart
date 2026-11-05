import 'package:brainbox/core/theme/app_theme.dart';
import 'package:brainbox/data/repositories/daily_challenge_repository.dart';
import 'package:brainbox/data/repositories/lesson_progress_repository.dart';
import 'package:brainbox/data/repositories/lesson_repository.dart' as lr;
import 'package:brainbox/data/services/storage_backend.dart';
import 'package:brainbox/data/services/storage_service.dart';
import 'package:brainbox/presentation/providers/app_provider.dart';
import 'package:brainbox/presentation/screens/home_screen.dart';
import 'package:brainbox/presentation/screens/learning_screen.dart';
import 'package:brainbox/presentation/screens/profile_screen.dart';
import 'package:brainbox/presentation/screens/settings_screen.dart';
import 'package:brainbox/presentation/screens/community_screen.dart';
import 'package:brainbox/presentation/screens/lesson_screen.dart';
import 'package:brainbox/presentation/screens/daily_challenge_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  Future<AppProvider> initialize(WidgetTester tester) async {
    StorageService.resetForTesting();
    await StorageService.init(backend: MemoryStorageBackend());
    final provider = AppProvider();
    await tester.runAsync(provider.initialize);
    addTearDown(provider.dispose);
    return provider;
  }

  Future<void> mount(
    WidgetTester tester,
    AppProvider provider,
    Widget screen,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(body: screen),
        ),
      ),
    );
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
  }

  for (final entry in <String, Widget>{
    'home': const HomeScreen(),
    'learning': const LearningScreen(),
    'profile': const ProfileScreen(),
    'settings': const SettingsScreen(),
    'community': const CommunityScreen(),
  }.entries) {
    testWidgets('populated ${entry.key} fits compact phones', (tester) async {
      tester.view.physicalSize = const Size(320, 850);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final provider = await initialize(tester);
      await mount(tester, provider, entry.value);
      expect(tester.takeException(), isNull);
      final scroll = find.byType(CustomScrollView).first;
      for (var i = 0; i < 4; i++) {
        await tester.drag(scroll, const Offset(0, -400));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });
  }

  testWidgets('completed challenge retains the selected date and score', (
    tester,
  ) async {
    final provider = await initialize(tester);
    final date = DateTime(2024, 1, 15);
    await DailyChallengeRepository.markCompletedForDate(date, 3);
    await mount(tester, provider, DailyChallengeScreen(fixedDate: date));
    expect(find.textContaining('3/5'), findsOneWidget);
  });

  testWidgets('resuming a correct multiple choice answer preserves feedback', (
    tester,
  ) async {
    final provider = await initialize(tester);
    final lesson = provider.lessonsFor('sql-basics').first;
    final index = lesson.steps.indexWhere(
      (s) => s.type == lr.LessonStepType.multipleChoice,
    );
    final step = lesson.steps[index];
    await LessonProgressRepository.saveProgress(
      courseId: 'sql-basics',
      lessonId: lesson.id,
      currentStepIndex: index,
      answeredSteps: {index: step.correctAnswer!},
      isFinished: false,
    );
    await mount(
      tester,
      provider,
      LessonScreen(courseId: 'sql-basics', initialLessonId: lesson.id),
    );
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
    expect(find.text(step.explanation!), findsOneWidget);
    final feedbackIcons = find.byIcon(Icons.check_circle_rounded);
    expect(feedbackIcons, findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
