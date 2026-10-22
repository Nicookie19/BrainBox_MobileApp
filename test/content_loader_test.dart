import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:brainbox/data/repositories/content_loader.dart';
import 'package:brainbox/data/services/storage_service.dart';
import 'package:brainbox/data/models/content_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    StorageService.resetForTesting();
    await StorageService.init();
    ContentLoader.resetForTesting();
  });

  group('ContentLoader validation', () {
    test(
      'loads all learning paths and courses without validation errors',
      () async {
        await ContentLoader.initialize();

        final paths = ContentLoader.getLearningPaths();
        expect(paths.length, 3);

        // Verify each path has 3 courses
        for (final path in paths) {
          final courses = ContentLoader.getCoursesForPath(path.id);
          expect(
            courses.length,
            3,
            reason: 'Path ${path.id} should have 3 courses',
          );

          for (final course in courses) {
            expect(course.modules.length, greaterThanOrEqualTo(1));
            expect(course.totalLessons, greaterThanOrEqualTo(4));

            // Verify each lesson has 5-8 steps and at least 3 step types
            for (final module in course.modules) {
              for (final lesson in module.lessons) {
                expect(lesson.steps.length, greaterThanOrEqualTo(5));
                expect(lesson.steps.length, lessThanOrEqualTo(8));

                final stepTypes = <StepType>{};
                for (final step in lesson.steps) {
                  stepTypes.add(step.type);
                }
                expect(
                  stepTypes.length,
                  greaterThanOrEqualTo(3),
                  reason:
                      'Lesson ${lesson.id} should use at least 3 step types',
                );
              }
            }
          }
        }
      },
    );

    test('learning paths have correct structure', () async {
      await ContentLoader.initialize();

      final webPath = ContentLoader.getLearningPath('web_development');
      expect(webPath, isNotNull);
      expect(webPath!.courseIds, [
        'frontend_foundations',
        'javascript_essentials',
        'react_basics',
      ]);

      final progPath = ContentLoader.getLearningPath(
        'programming_fundamentals',
      );
      expect(progPath, isNotNull);
      expect(progPath!.courseIds, [
        'python_essentials',
        'data_structures',
        'git_github',
      ]);

      final backendPath = ContentLoader.getLearningPath('backend_cloud');
      expect(backendPath, isNotNull);
      expect(backendPath!.courseIds, [
        'sql_basics',
        'http_apis',
        'machine_learning_basics',
      ]);
    });

    test('can retrieve specific lessons and steps', () async {
      await ContentLoader.initialize();

      final lesson = ContentLoader.getLesson(
        'frontend_foundations',
        'module_1',
        'lesson_1',
      );
      expect(lesson, isNotNull);
      expect(lesson!.title, 'HTML Document Structure');

      final step = ContentLoader.getStep(
        'frontend_foundations',
        'module_1',
        'lesson_1',
        0,
      );
      expect(step, isNotNull);
      expect(step!.type, StepType.explanation);
    });
  });
}
