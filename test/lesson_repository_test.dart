import 'package:brainbox/data/repositories/lesson_progress_repository.dart';
import 'package:brainbox/data/repositories/content_loader.dart';
import 'package:brainbox/data/models/content_models.dart';
import 'package:brainbox/data/services/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('all multiple-choice lessons expose valid answer choices', () async {
    await ContentLoader.initialize();
    for (final courseId in const [
      'frontend_foundations',
      'python_essentials',
      'data_structures',
      'sql_basics',
    ]) {
      final course = ContentLoader.getCourse(courseId);
      expect(
        course,
        isNotNull,
        reason: '$courseId should load its lesson asset',
      );

      if (course != null) {
        for (final module in course.modules) {
          for (final lesson in module.lessons) {
            for (final step in lesson.steps) {
              if (step.type == StepType.multipleChoice) {
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
      }
    }
  });

  test('lesson progress saves and restores answer state', () async {
    SharedPreferences.setMockInitialValues({});
    StorageService.resetForTesting();
    await StorageService.init();
    ContentLoader.resetForTesting();
    await ContentLoader.initialize();

    await LessonProgressRepository.saveProgressImmediate(
      courseId: 'python_essentials',
      lessonId: 'lesson_1',
      currentStepIndex: 3,
      answeredSteps: {2: 1, 3: 'test'},
      hintsUsed: {2: 1},
      isFinished: false,
      contentVersion: 1,
    );

    final restored = await LessonProgressRepository.loadProgress(
      'python_essentials',
      'lesson_1',
    );
    expect(restored?.currentStepIndex, 3);
    expect(restored?.answeredSteps, {2: 1, 3: 'test'});
    expect(restored?.hintsUsed, {2: 1});
    expect(restored?.isFinished, isFalse);
    expect(restored?.contentVersion, 1);
  });
}
