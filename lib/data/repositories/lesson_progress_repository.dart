import 'package:brainbox/data/services/storage_service.dart';

class LessonProgressRepository {
  /// Saves the current lesson progress
  static Future<void> saveProgress({
    required String courseId,
    required String lessonId,
    required int currentStepIndex,
    required Map<int, int> answeredSteps,
    required bool isFinished,
  }) async {
    final result = await StorageService.saveLessonProgress(
      courseId: courseId,
      lessonId: lessonId,
      currentStepIndex: currentStepIndex,
      answeredSteps: answeredSteps,
      isFinished: isFinished,
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
    await StorageService.clearLessonProgress(courseId, lessonId);
  }
}
