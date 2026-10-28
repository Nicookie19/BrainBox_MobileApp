import 'package:brainbox/data/repositories/lesson_progress_repository.dart';
import 'package:brainbox/data/repositories/lesson_repository.dart';
import 'package:brainbox/data/services/storage_backend.dart';
import 'package:brainbox/data/services/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('all multiple-choice lessons expose valid answer choices', () async {
    for (final courseId in const [
      'frontend-foundations',
      'python-essentials',
      'data-structures',
      'sql-basics',
      'flutter-from-zero',
      'machine-learning-basics',
      'networking-fundamentals',
    ]) {
      final course = await LessonRepository.getCourseLessons(courseId);
      expect(
        course,
        isNotNull,
        reason: '$courseId should load its lesson asset',
      );

      for (final lesson in course!.modules.expand((module) => module.lessons)) {
        for (final step in lesson.steps) {
          if (step.type == LessonStepType.multipleChoice) {
            expect(step.options, isNotNull);
            expect(step.options!.length, greaterThanOrEqualTo(2));
            expect(
              step.correctAnswer,
              inInclusiveRange(0, step.options!.length - 1),
            );
          }
        }
      }
    }
  });

  test('every sample course ships lessons', () {
    for (final courseId in const [
      'frontend-foundations',
      'python-essentials',
      'data-structures',
      'sql-basics',
      'flutter-from-zero',
      'machine-learning-basics',
      'networking-fundamentals',
    ]) {
      expect(LessonRepository.hasLessons(courseId), isTrue, reason: courseId);
    }
  });

  test('code-ordering steps are valid and not already solved', () async {
    for (final courseId in const [
      'frontend-foundations',
      'python-essentials',
      'data-structures',
      'sql-basics',
      'flutter-from-zero',
      'machine-learning-basics',
      'networking-fundamentals',
    ]) {
      final course = await LessonRepository.getCourseLessons(courseId);
      for (final lesson in course!.modules.expand((m) => m.lessons)) {
        for (final step in lesson.steps) {
          if (step.type != LessonStepType.codeOrdering) continue;
          final order = step.correctOrder!;
          final sorted = [...order]..sort();
          expect(
            sorted,
            List<int>.generate(step.snippets!.length, (i) => i),
            reason: '$courseId ${lesson.id}: correctOrder must be a permutation',
          );
          expect(
            order,
            isNot(List<int>.generate(order.length, (i) => i)),
            reason: '$courseId ${lesson.id}: ordering is solved before the user starts',
          );
        }
      }
    }
  });

  test('lesson progress saves and restores answer state', () async {
    SharedPreferences.setMockInitialValues({});
    StorageService.resetForTesting();
    await StorageService.init(backend: MemoryStorageBackend());
    await LessonProgressRepository.saveProgress(
      courseId: 'python-essentials',
      lessonId: 'lesson_1',
      currentStepIndex: 3,
      answeredSteps: {2: 1, 3: 0},
      isFinished: false,
    );

    final restored = await LessonProgressRepository.loadProgress(
      'python-essentials',
      'lesson_1',
    );
    expect(restored?.currentStepIndex, 3);
    expect(restored?.answeredSteps, {2: 1, 3: 0});
    expect(restored?.isFinished, isFalse);
  });
}
