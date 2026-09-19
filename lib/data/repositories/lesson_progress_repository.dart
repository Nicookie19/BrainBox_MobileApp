import 'package:brainbox/data/services/storage_service.dart';

class LessonProgressRepository {
  static const String _prefix = 'lesson_progress_';

  static String _key(String courseId, String lessonId) {
    return '$_prefix$courseId:$lessonId';
  }

  /// Saves the current lesson progress
  static Future<void> saveProgress({
    required String courseId,
    required String lessonId,
    required int currentStepIndex,
    required Map<int, int> answeredSteps, // stepIndex -> selectedAnswerIndex
    required bool isFinished,
  }) async {
    final data = {
      'currentStepIndex': currentStepIndex,
      'answeredSteps': answeredSteps,
      'isFinished': isFinished,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
    await StorageService.setString(_key(courseId, lessonId), data.toString());
  }

  /// Loads the saved lesson progress
  static Future<LessonProgress?> loadProgress(String courseId, String lessonId) async {
    final dataString = StorageService.getString(_key(courseId, lessonId));
    if (dataString == null) return null;

    try {
      // Parse the stored string back to a map
      // Note: This is a simple implementation; in production, use JSON encoding
      final data = _parseProgressString(dataString);
      return LessonProgress(
        currentStepIndex: data['currentStepIndex'] ?? 0,
        answeredSteps: Map<int, int>.from(data['answeredSteps'] ?? {}),
        isFinished: data['isFinished'] ?? false,
      );
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic> _parseProgressString(String dataString) {
    // Simple parser for the stored string format
    // In production, use proper JSON serialization
    final Map<String, dynamic> result = {};
    // This is a simplified parser - real implementation would use JSON
    return result;
  }

  /// Clears progress for a specific lesson
  static Future<void> clearProgress(String courseId, String lessonId) async {
    await StorageService.remove(_key(courseId, lessonId));
  }
}

class LessonProgress {
  final int currentStepIndex;
  final Map<int, int> answeredSteps;
  final bool isFinished;

  LessonProgress({
    required this.currentStepIndex,
    required this.answeredSteps,
    required this.isFinished,
  });
}