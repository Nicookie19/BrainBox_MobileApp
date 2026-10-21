import 'dart:convert';

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
    final data = <String, dynamic>{
      'currentStepIndex': currentStepIndex,
      'answeredSteps': answeredSteps.map(
        (key, value) => MapEntry('$key', value),
      ),
      'isFinished': isFinished,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
    await StorageService.setString(_key(courseId, lessonId), jsonEncode(data));
  }

  /// Loads the saved lesson progress
  static Future<LessonProgress?> loadProgress(
    String courseId,
    String lessonId,
  ) async {
    final dataString = StorageService.getString(_key(courseId, lessonId));
    if (dataString == null) return null;

    try {
      final data = jsonDecode(dataString) as Map<String, dynamic>;
      final answers = Map<String, dynamic>.from(
        data['answeredSteps'] as Map? ?? {},
      );
      return LessonProgress(
        currentStepIndex: data['currentStepIndex'] as int? ?? 0,
        answeredSteps: answers.map(
          (key, value) => MapEntry(int.parse(key), value as int),
        ),
        isFinished: data['isFinished'] as bool? ?? false,
      );
    } catch (_) {
      return null;
    }
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
