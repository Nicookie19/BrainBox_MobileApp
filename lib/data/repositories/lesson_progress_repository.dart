import 'dart:async';

import 'package:brainbox/data/services/storage_service.dart';

class LessonProgressRepository {
  static Timer? _debounceTimer;
  static const Duration _debounceDelay = Duration(milliseconds: 500);

  /// Saves the current lesson progress with debouncing
  static Future<void> saveProgress({
    required String courseId,
    required String lessonId,
    required int currentStepIndex,
    required Map<int, Object> answeredSteps,
    required Map<int, int> hintsUsed,
    required bool isFinished,
    required int contentVersion,
  }) async {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, () async {
      final result = await StorageService.saveLessonProgress(
        courseId: courseId,
        lessonId: lessonId,
        currentStepIndex: currentStepIndex,
        answeredSteps: answeredSteps,
        hintsUsed: hintsUsed,
        isFinished: isFinished,
        contentVersion: contentVersion,
      );
      if (result.isFailure) {
        // Log error but don't throw - fail silently for progress saving
      }
    });
  }

  /// Saves the current lesson progress immediately (for critical updates like completion)
  static Future<void> saveProgressImmediate({
    required String courseId,
    required String lessonId,
    required int currentStepIndex,
    required Map<int, Object> answeredSteps,
    required Map<int, int> hintsUsed,
    required bool isFinished,
    required int contentVersion,
  }) async {
    _debounceTimer?.cancel();
    final result = await StorageService.saveLessonProgress(
      courseId: courseId,
      lessonId: lessonId,
      currentStepIndex: currentStepIndex,
      answeredSteps: answeredSteps,
      hintsUsed: hintsUsed,
      isFinished: isFinished,
      contentVersion: contentVersion,
    );
    if (result.isFailure) {
      // Log error but don't throw - fail silently for progress saving
    }
  }

  /// Loads the saved lesson progress
  static Future<LessonProgress?> loadProgress(
    String courseId,
    String lessonId,
  ) async {
    final result = StorageService.loadLessonProgress(courseId, lessonId);
    if (result.isFailure) {
      return null;
    }
    return result.value;
  }

  /// Clears progress for a specific lesson
  static Future<void> clearProgress(String courseId, String lessonId) async {
    _debounceTimer?.cancel();
    await StorageService.clearLessonProgress(courseId, lessonId);
  }

  /// Checks if saved progress is compatible with current lesson content
  static Future<bool> isProgressValid(
    String courseId,
    String lessonId,
    int currentContentVersion,
  ) async {
    final progress = await loadProgress(courseId, lessonId);
    if (progress == null) return false;
    return progress.contentVersion == currentContentVersion;
  }

  /// Gets a summary of saved progress for display in continue/recent areas
  static Future<LessonProgressSummary?> getProgressSummary(
    String courseId,
    String lessonId,
  ) async {
    final progress = await loadProgress(courseId, lessonId);
    if (progress == null) return null;

    final lesson = await _getLessonInfo(courseId, lessonId);
    if (lesson == null) return null;

    final totalSteps = lesson.steps.length;
    final completedSteps = progress.answeredSteps.length;
    final progressPercent = totalSteps > 0 ? completedSteps / totalSteps : 0.0;

    return LessonProgressSummary(
      courseId: courseId,
      lessonId: lessonId,
      lessonTitle: lesson.title,
      currentStepIndex: progress.currentStepIndex,
      totalSteps: totalSteps,
      completedSteps: completedSteps,
      progressPercent: progressPercent,
      lastUpdated: progress.lastUpdated,
      isFinished: progress.isFinished,
    );
  }

  /// Gets lesson info from content loader
  static dynamic _getLessonInfo(String courseId, String lessonId) {
    // This would ideally use ContentLoader
    // For now, return null - the UI can handle missing info
    return null;
  }

  static void dispose() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }
}

class LessonProgressSummary {
  final String courseId;
  final String lessonId;
  final String lessonTitle;
  final int currentStepIndex;
  final int totalSteps;
  final int completedSteps;
  final double progressPercent;
  final DateTime? lastUpdated;
  final bool isFinished;

  LessonProgressSummary({
    required this.courseId,
    required this.lessonId,
    required this.lessonTitle,
    required this.currentStepIndex,
    required this.totalSteps,
    required this.completedSteps,
    required this.progressPercent,
    this.lastUpdated,
    required this.isFinished,
  });
}
