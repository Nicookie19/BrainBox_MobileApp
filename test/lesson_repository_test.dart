import 'package:brainbox/data/repositories/lesson_progress_repository.dart';
import 'package:brainbox/data/repositories/lesson_repository.dart';
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

    // Verify course loads
    final course = ContentLoader.getCourse('python_essentials');
    print('Course loaded: ${course?.courseId}');
    print('Modules: ${course?.modules.length}');
    if (course != null && course.modules.isNotEmpty) {
      print('First module lessons: ${course.modules[0].lessons.length}');
      print('First lesson id: ${course.modules[0].lessons[0].id}');
    }

    final saveResult = await StorageService.saveLessonProgress(
      courseId: 'python_essentials',
      lessonId: 'lesson_1',
      currentStepIndex: 3,
      answeredSteps: {2: 1, 3: 'test'},
      isFinished: false,
    );
    print('Save result: $saveResult');

    final dataString = StorageService.prefs.getString(
      'lesson_progress_python_essentials:lesson_1',
    );
    print('Stored data: $dataString');

    final loadResult = StorageService.loadLessonProgress(
      'python_essentials',
      'lesson_1',
    );
    print('Load result: $loadResult');
    print('Load value: ${loadResult.value}');
    print('Load error: ${loadResult.error}');

    final restored = await LessonProgressRepository.loadProgress(
      'python_essentials',
      'lesson_1',
    );
    print('Restored: $restored');
    expect(restored?.currentStepIndex, 3);
    expect(restored?.answeredSteps, {2: 1, 3: 'test'});
    expect(restored?.isFinished, isFalse);
  });
}
