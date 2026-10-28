import 'package:brainbox/data/models/user_models.dart';
import 'package:brainbox/data/repositories/course_repository.dart';
import 'package:brainbox/data/services/storage_backend.dart';
import 'package:brainbox/data/services/storage_service.dart';
import 'package:brainbox/presentation/providers/app_provider.dart';
import 'package:flutter_test/flutter_test.dart';

Future<AppProvider> _newProvider() async {
  StorageService.resetForTesting();
  await StorageService.init(backend: MemoryStorageBackend());
  await CourseRepository.initializeSampleCourses();
  final provider = AppProvider();
  await provider.initialize();
  return provider;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a new course starts at zero progress', () async {
    final provider = await _newProvider();
    expect(provider.courseProgress('sql-basics'), 0);
    expect(provider.isCourseCompleted('sql-basics'), isFalse);
    expect(provider.nextLessonIdFor('sql-basics'), 'lesson_1');
  });

  test('progress follows completed lessons', () async {
    final provider = await _newProvider();
    await provider.completeLesson('sql-basics', lessonId: 'lesson_1');

    expect(provider.courseProgress('sql-basics'), closeTo(0.25, 0.0001));
    expect(provider.nextLessonIdFor('sql-basics'), 'lesson_2');
    expect(provider.isEnrolled('sql-basics'), isTrue);
  });

  test('completing the same lesson twice awards XP once', () async {
    final provider = await _newProvider();
    await provider.completeLesson('sql-basics', lessonId: 'lesson_1');
    final xpAfterFirst = provider.profile!.totalXp;

    await provider.completeLesson('sql-basics', lessonId: 'lesson_1');

    expect(provider.profile!.totalXp, xpAfterFirst);
    expect(provider.profile!.stats.totalLessonsCompleted, 1);
  });

  test('finishing every lesson completes the course and pays rewards', () async {
    final provider = await _newProvider();
    final lessons = provider.lessonsFor('sql-basics');
    expect(lessons, isNotEmpty);

    for (final lesson in lessons) {
      await provider.completeLesson('sql-basics', lessonId: lesson.id);
    }

    final profile = provider.profile!;
    expect(provider.isCourseCompleted('sql-basics'), isTrue);
    expect(provider.courseProgress('sql-basics'), 1.0);
    expect(profile.stats.totalCoursesCompleted, 1);
    expect(profile.stats.totalLessonsCompleted, lessons.length);

    final starter = profile.achievements.firstWhere(
      (a) => a.id == 'first_course',
    );
    expect(starter.isUnlocked, isTrue);

    final lessonXp = lessons.fold<int>(0, (sum, l) => sum + l.xpReward);
    expect(profile.totalXp, lessonXp + starter.xpReward);
    expect(profile.level.number, UserLevel.getLevelForXp(profile.totalXp).number);

    expect(provider.completedCourses.map((c) => c.id), contains('sql-basics'));
    expect(
      provider.recommendedCourses.map((c) => c.id),
      isNot(contains('sql-basics')),
    );
  });

  test('completing a challenge starts a streak and marks today active', () async {
    final provider = await _newProvider();
    await provider.completeChallenge();

    expect(provider.profile!.xp, 50);
    expect(provider.profile!.stats.currentStreakDays, 1);
    expect(provider.currentStreak, 1);

    final todayIndex = DateTime.now().toUtc().weekday - 1;
    expect(provider.weekActivity[todayIndex], isTrue);
    expect(provider.weeklyStudyMinutes, greaterThan(0));
  });

  test('a streak lapses after a missed day', () async {
    final provider = await _newProvider();
    final base = provider.profile!;
    final profile = base.copyWith(
      stats: base.stats.copyWith(currentStreakDays: 5),
      lastLessonCompletedAt: DateTime.utc(2026, 10, 20, 9),
    );

    expect(
      AppProvider.effectiveStreak(profile, now: DateTime.utc(2026, 10, 20, 23)),
      5,
    );
    expect(
      AppProvider.effectiveStreak(profile, now: DateTime.utc(2026, 10, 21, 8)),
      5,
    );
    expect(
      AppProvider.effectiveStreak(profile, now: DateTime.utc(2026, 10, 22, 8)),
      0,
    );
  });

  test('a level restored from JSON still finds its next level', () {
    final current = UserLevel.allLevels[2];
    final restored = UserLevel.fromJson(current.toJson());

    expect(
      UserLevel.getNextLevel(restored)?.number,
      UserLevel.allLevels[3].number,
    );
  });

  test('profile survives a restart', () async {
    final provider = await _newProvider();
    await provider.completeLesson('sql-basics', lessonId: 'lesson_1');

    final reloaded = AppProvider();
    await reloaded.initialize();

    expect(reloaded.profile!.completedLessonIds, contains('sql-basics:lesson_1'));
    expect(reloaded.courseProgress('sql-basics'), closeTo(0.25, 0.0001));
  });
}
