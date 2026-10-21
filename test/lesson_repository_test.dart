import 'package:brainbox/data/repositories/lesson_progress_repository.dart';
import 'package:brainbox/data/repositories/lesson_repository.dart';
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

  test('lesson progress saves and restores answer state', () async {
    SharedPreferences.setMockInitialValues({});
    StorageService.resetForTesting();
    await StorageService.init();
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
