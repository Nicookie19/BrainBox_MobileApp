import 'package:brainbox/data/models/user_models.dart';
import 'package:brainbox/data/services/storage_service.dart';
import 'package:brainbox/data/repositories/content_loader.dart';
import 'package:brainbox/core/utils/clock.dart';

/// Result of a completion operation
class CompletionResult {
  final bool success;
  final int xpAwarded;
  final bool leveledUp;
  final UserLevel? newLevel;
  final List<Achievement> newlyUnlockedAchievements;
  final String? error;

  const CompletionResult._({
    required this.success,
    this.xpAwarded = 0,
    this.leveledUp = false,
    this.newLevel,
    this.newlyUnlockedAchievements = const [],
    this.error,
  });

  factory CompletionResult.success({
    required int xpAwarded,
    required bool leveledUp,
    UserLevel? newLevel,
    List<Achievement> newlyUnlockedAchievements = const [],
  }) => CompletionResult._(
    success: true,
    xpAwarded: xpAwarded,
    leveledUp: leveledUp,
    newLevel: newLevel,
    newlyUnlockedAchievements: newlyUnlockedAchievements,
  );

  factory CompletionResult.failure(String error) =>
      CompletionResult._(success: false, error: error);

  factory CompletionResult.alreadyCompleted() =>
      CompletionResult._(success: true, xpAwarded: 0, leveledUp: false);
}

/// Service for handling lesson/challenge completion with idempotency and atomic writes
class CompletionService {
  static const int _lessonXp = 25;
  static const int _challengeXp = 50;

  /// Completes a lesson atomically with idempotency check
  /// Returns CompletionResult with XP awarded, level up info, and newly unlocked achievements
  static Future<CompletionResult> completeLesson({
    required UserProfile profile,
    required String courseId,
    required String lessonId,
    required Clock clock,
  }) async {
    final lessonIdKey = '$courseId:$lessonId';

    // Idempotency check - already completed
    if (profile.completedLessonIds.contains(lessonIdKey)) {
      return CompletionResult.alreadyCompleted();
    }

    // Get current time in local day
    final now = clock.now();
    final todayLocal = now.startOfLocalDay;

    try {
      // Load current course progress
      final courseProgressResult = StorageService.getCourseProgress(courseId);
      final courseProgress = courseProgressResult.isSuccess
          ? courseProgressResult.value
          : null;

      final contentCourse = ContentLoader.getCourse(
        courseId.replaceAll('-', '_'),
      );
      final lesson = contentCourse?.modules
          .expand((module) => module.lessons)
          .where((item) => item.id == lessonId)
          .firstOrNull;
      final lessonXp = lesson?.xpReward ?? _lessonXp;
      final totalLessons =
          contentCourse?.modules.fold<int>(
            0,
            (total, module) => total + module.lessons.length,
          ) ??
          1;

      // Calculate new XP and level
      final newTotalXp = profile.totalXp + lessonXp;
      final oldLevel = profile.level;

      // Calculate streak
      final (newStreak, newLongestStreak) = _calculateStreak(
        profile: profile,
        todayLocal: todayLocal,
      );

      // Update course progress
      final updatedCourseProgress =
          (courseProgress ??
                  CourseProgress(
                    courseId: courseId,
                    userId: profile.id,
                    completedModules: 0,
                    totalModules: 0,
                    completedLessons: 0,
                    totalLessons: totalLessons,
                    completedQuizzes: 0,
                    totalQuizzes: 0,
                    completedProjects: 0,
                    totalProjects: 0,
                    totalStudyMinutes: 0,
                    startedAt: clock.now(),
                    lastAccessedAt: clock.now(),
                    isEnrolled: true,
                  ))
              .copyWith(
                completedLessons: (courseProgress?.completedLessons ?? 0) + 1,
                totalLessons: totalLessons,
                totalStudyMinutes:
                    (courseProgress?.totalStudyMinutes ?? 0) + 10,
                lastAccessedAt: clock.now(),
              );
      final courseCompleted =
          updatedCourseProgress.completedLessons >=
          updatedCourseProgress.totalLessons;
      final completedCourseIds = List<String>.from(profile.completedCourseIds);
      if (courseCompleted && !completedCourseIds.contains(courseId)) {
        completedCourseIds.add(courseId);
      }
      final finalizedCourseProgress = updatedCourseProgress.copyWith(
        isCompleted: courseCompleted,
        completedAt: courseCompleted ? clock.now() : null,
      );

      // Update completed lesson IDs
      final completedLessonIds = List<String>.from(profile.completedLessonIds);
      completedLessonIds.add(lessonIdKey);

      // Update enrolled course IDs
      final enrolledIds = List<String>.from(profile.enrolledCourseIds);
      if (!enrolledIds.contains(courseId)) {
        enrolledIds.add(courseId);
      }

      // Evaluate achievements
      final newStats = profile.stats.copyWith(
        totalLessonsCompleted: profile.stats.totalLessonsCompleted + 1,
        currentStreakDays: newStreak,
        longestStreakDays: newStreak > profile.stats.longestStreakDays
            ? newStreak
            : profile.stats.longestStreakDays,
        totalStudyMinutes: profile.stats.totalStudyMinutes + 10,
      );

      final newAchievements = _evaluateAchievements(
        profile.achievements,
        newStats: newStats,
        completedCourseIds: completedCourseIds,
      );

      // Find newly unlocked achievements
      final newlyUnlocked = <Achievement>[];
      for (int i = 0; i < newAchievements.length; i++) {
        if (newAchievements[i].isUnlocked &&
            !profile.achievements[i].isUnlocked) {
          newlyUnlocked.add(newAchievements[i]);
        }
      }

      final achievementXp = newlyUnlocked.fold<int>(
        0,
        (total, achievement) => total + achievement.xpReward,
      );
      final finalTotalXp = newTotalXp + achievementXp;

      // Prepare updated profile
      final updatedProfile = profile.copyWith(
        xp: profile.xp + lessonXp + achievementXp,
        totalXp: finalTotalXp,
        level: UserLevel.getLevelForXp(finalTotalXp),
        enrolledCourseIds: enrolledIds,
        completedCourseIds: completedCourseIds,
        completedLessonIds: completedLessonIds,
        lastActiveAt: clock.now(),
        lastLessonCompletedAt: clock.now(),
        stats: newStats,
        achievements: newAchievements,
      );

      // Atomic write: save all data
      await Future.wait([
        StorageService.saveCourseProgress(finalizedCourseProgress),
        StorageService.saveUserProfile(updatedProfile),
        StorageService.markActivity(todayLocal),
      ]);

      return CompletionResult.success(
        xpAwarded: lessonXp + achievementXp,
        leveledUp: UserLevel.getLevelForXp(finalTotalXp) != oldLevel,
        newLevel: UserLevel.getLevelForXp(finalTotalXp) != oldLevel
            ? UserLevel.getLevelForXp(finalTotalXp)
            : null,
        newlyUnlockedAchievements: newlyUnlocked,
      );
    } catch (e) {
      return CompletionResult.failure('Failed to complete lesson: $e');
    }
  }

  /// Completes a daily challenge atomically with idempotency check
  static Future<CompletionResult> completeDailyChallenge({
    required UserProfile profile,
    required DateTime date,
    required int score,
    required Clock clock,
  }) async {
    // Idempotency check - already completed today
    if (StorageService.isDailyChallengeCompleted(date)) {
      return CompletionResult.alreadyCompleted();
    }

    // Only award XP if score > 0 (or at least some threshold)
    if (score <= 0) {
      return CompletionResult.failure('Score must be positive');
    }

    try {
      final now = clock.now();
      final todayLocal = now.startOfLocalDay;

      // Calculate new XP and level
      final newTotalXp = profile.totalXp + _challengeXp;
      final oldLevel = profile.level;

      // Calculate streak (challenge completion counts for streak)
      final (newStreak, newLongestStreak) = _calculateStreak(
        profile: profile,
        todayLocal: todayLocal,
      );

      // Update stats
      final newStats = profile.stats.copyWith(
        currentStreakDays: newStreak,
        longestStreakDays: newStreak > profile.stats.longestStreakDays
            ? newStreak
            : profile.stats.longestStreakDays,
        totalStudyMinutes: profile.stats.totalStudyMinutes + 5,
      );

      // Evaluate achievements
      final newAchievements = _evaluateAchievements(
        profile.achievements,
        newStats: newStats,
        completedCourseIds: profile.completedCourseIds,
      );

      // Find newly unlocked achievements
      final newlyUnlocked = <Achievement>[];
      for (int i = 0; i < newAchievements.length; i++) {
        if (newAchievements[i].isUnlocked &&
            !profile.achievements[i].isUnlocked) {
          newlyUnlocked.add(newAchievements[i]);
        }
      }

      final achievementXp = newlyUnlocked.fold<int>(
        0,
        (total, achievement) => total + achievement.xpReward,
      );
      final finalTotalXp = newTotalXp + achievementXp;

      // Prepare updated profile
      final updatedProfile = profile.copyWith(
        xp: profile.xp + _challengeXp + achievementXp,
        totalXp: finalTotalXp,
        level: UserLevel.getLevelForXp(finalTotalXp),
        lastActiveAt: clock.now(),
        stats: newStats,
        achievements: newAchievements,
      );

      // Atomic write: save challenge completion and profile
      await Future.wait([
        StorageService.markDailyChallengeCompleted(date, score),
        StorageService.saveUserProfile(updatedProfile),
        StorageService.markActivity(todayLocal),
      ]);

      return CompletionResult.success(
        xpAwarded: _challengeXp + achievementXp,
        leveledUp: UserLevel.getLevelForXp(finalTotalXp) != oldLevel,
        newLevel: UserLevel.getLevelForXp(finalTotalXp) != oldLevel
            ? UserLevel.getLevelForXp(finalTotalXp)
            : null,
        newlyUnlockedAchievements: newlyUnlocked,
      );
    } catch (e) {
      return CompletionResult.failure('Failed to complete challenge: $e');
    }
  }

  /// Calculates streak based on last lesson date and today
  /// Returns (newStreak, newLongestStreak)
  static (int, int) _calculateStreak({
    required UserProfile profile,
    required DateTime todayLocal,
  }) {
    int newStreak = profile.stats.currentStreakDays;
    int newLongestStreak = profile.stats.longestStreakDays;
    DateTime? lastLessonDate = profile.lastLessonCompletedAt;

    if (lastLessonDate != null) {
      final lastLessonLocal = lastLessonDate.startOfLocalDay;

      if (lastLessonLocal == todayLocal.subtract(const Duration(days: 1))) {
        // Consecutive day - increment streak
        newStreak += 1;
      } else if (lastLessonLocal == todayLocal) {
        // Same day - streak unchanged
      } else if (lastLessonLocal.isBefore(
        todayLocal.subtract(const Duration(days: 1)),
      )) {
        // Gap - reset streak
        newStreak = 1;
      } else if (lastLessonLocal.isAfter(todayLocal)) {
        // Clock moved backwards - don't break streak, keep current
        // This handles DST, timezone changes, or manual clock adjustments
      }
    } else {
      // First lesson ever
      newStreak = 1;
    }

    if (newStreak > newLongestStreak) {
      newLongestStreak = newStreak;
    }

    return (newStreak, newLongestStreak);
  }

  /// Pure evaluator function for achievements
  /// Never re-unlocks already unlocked achievements
  static List<Achievement> _evaluateAchievements(
    List<Achievement> achievements, {
    required UserStats newStats,
    required List<String> completedCourseIds,
  }) {
    return achievements.map((achievement) {
      // If already unlocked, keep it unlocked with original unlock date
      if (achievement.isUnlocked) {
        return achievement;
      }

      int newProgress = achievement.progress;

      switch (achievement.type) {
        case AchievementType.lessonsCompleted:
          newProgress = newStats.totalLessonsCompleted;
          break;
        case AchievementType.streakDays:
          newProgress = newStats.currentStreakDays;
          break;
        case AchievementType.coursesCompleted:
          newProgress = completedCourseIds.length;
          break;
        default:
          newProgress = achievement.progress;
      }

      final isUnlocked = newProgress >= achievement.target;
      return achievement.copyWith(
        progress: newProgress.clamp(0, achievement.target),
        isUnlocked: isUnlocked,
        unlockedAt: isUnlocked ? DateTime.now() : null,
      );
    }).toList();
  }
}
