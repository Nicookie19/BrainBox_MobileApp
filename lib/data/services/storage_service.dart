import 'dart:convert';

import '../models/user_models.dart';
import 'local_database_service.dart';
import '../../core/utils/clock.dart';

class StorageResult<T> {
  final T? value;
  final StorageError? error;

  const StorageResult._({this.value, this.error});

  factory StorageResult.success(T value) => StorageResult._(value: value);
  factory StorageResult.failure(StorageError error) =>
      StorageResult._(error: error);

  bool get isSuccess => error == null;
  bool get isFailure => error != null;

  T getOrDefault(T defaultValue) => value ?? defaultValue;
  T getOrThrow() {
    if (error != null) throw StorageException(error!);
    return value!;
  }

  StorageResult<R> map<R>(R Function(T?) f) {
    if (isSuccess) {
      return StorageResult.success(f(value));
    }
    return StorageResult.failure(error!);
  }
}

class StorageError {
  final String message;
  final String? key;
  final dynamic originalError;

  const StorageError(this.message, {this.key, this.originalError});

  @override
  String toString() =>
      'StorageError($key): $message${originalError != null ? ' ($originalError)' : ''}';
}

class StorageException implements Exception {
  final StorageError error;
  StorageException(this.error);
  @override
  String toString() => error.toString();
}

class StorageService {
  static const int _schemaVersion = 2;
  static const String _schemaVersionKey = 'schema_version';
  static const String _userProfileKey = 'user_profile';
  static const String _courseProgressKey = 'course_progress_';
  static const String _preferencesKey = 'user_preferences';
  static const String _downloadsKey = 'downloads';
  static const String _lastSyncKey = 'last_sync';
  static const String _dailyChallengeCompletionKey =
      'daily_challenge_completed_';
  static const String _dailyChallengeScoreKey = 'daily_challenge_score_';
  static const String _lessonProgressPrefix = 'lesson_progress_';
  static const String _activityPrefix = 'activity_';

  static LocalPreferences? _prefs;
  static Clock _clock = Clock.real;

  static Future<void> init({Clock? clock}) async {
    await LocalDatabaseService.initialize();
    _prefs = LocalPreferences();
    if (clock != null) _clock = clock;
    await _runMigrations();
  }

  static void setClockForTesting(Clock clock) {
    _clock = clock;
  }

  static void resetForTesting() {
    _prefs = null;
    _clock = Clock.real;
  }

  static LocalPreferences get prefs {
    if (_prefs == null) {
      throw StateError('StorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  static Future<void> _runMigrations() async {
    final currentVersion = prefs.getInt(_schemaVersionKey) ?? 0;
    if (currentVersion >= _schemaVersion) return;

    if (currentVersion == 0) {
      await _migrateV1();
    }
    if (currentVersion <= 1) {
      await _migrateV2();
    }

    await prefs.setInt(_schemaVersionKey, _schemaVersion);
  }

  static Future<void> _migrateV1() async {
    // Migration from no schema to v1: add schema version key
    // No data transformation needed for v1
  }

  static Future<void> _migrateV2() async {
    // Migration v2: Convert streak data from UTC to local day keys
    // Old streak data used UTC dates; new format uses local day keys
    // We read the old UTC date and convert to local day key for display logic
    // The stored streak data format remains the same; interpretation changes at read time
    // This migration is a no-op for stored data but documents the semantic change
  }

  // Safe JSON read/write helpers
  static StorageResult<String> safeReadString(String key) {
    try {
      final value = prefs.getString(key);
      return StorageResult.success(value ?? '');
    } catch (e) {
      return StorageResult.failure(
        StorageError('Failed to read string', key: key, originalError: e),
      );
    }
  }

  static Future<StorageResult<void>> safeWriteString(
    String key,
    String value,
  ) async {
    try {
      await prefs.setString(key, value);
      return StorageResult.success(null);
    } catch (e) {
      return StorageResult.failure(
        StorageError('Failed to write string', key: key, originalError: e),
      );
    }
  }

  static StorageResult<T> safeReadJson<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson, {
    T? defaultValue,
  }) {
    try {
      final jsonString = prefs.getString(key);
      if (jsonString == null || jsonString.isEmpty) {
        return StorageResult.success(defaultValue as T);
      }
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final value = fromJson(jsonMap);
      return StorageResult.success(value);
    } catch (e) {
      return StorageResult.failure(
        StorageError('Failed to parse JSON', key: key, originalError: e),
      );
    }
  }

  static Future<StorageResult<void>> safeWriteJson<T>(
    String key,
    T value,
    Map<String, dynamic> Function(T) toJson,
  ) async {
    try {
      final jsonString = jsonEncode(toJson(value));
      await prefs.setString(key, jsonString);
      return StorageResult.success(null);
    } catch (e) {
      return StorageResult.failure(
        StorageError('Failed to serialize JSON', key: key, originalError: e),
      );
    }
  }

  // User Profile
  static Future<StorageResult<void>> saveUserProfile(
    UserProfile profile,
  ) async {
    final result = await safeWriteJson(
      _userProfileKey,
      profile,
      (p) => p.toJson(),
    );
    if (result.isSuccess) {}
    return result;
  }

  static StorageResult<UserProfile?> getUserProfile() {
    return safeReadJson<UserProfile?>(
      _userProfileKey,
      (json) => UserProfile.fromJson(json),
      defaultValue: null,
    );
  }

  static Future<StorageResult<void>> clearUserProfile() async {
    try {
      await prefs.remove(_userProfileKey);
      return StorageResult.success(null);
    } catch (e) {
      return StorageResult.failure(
        StorageError(
          'Failed to clear user profile',
          key: _userProfileKey,
          originalError: e,
        ),
      );
    }
  }

  // Course Progress
  static Future<StorageResult<void>> saveCourseProgress(
    CourseProgress progress,
  ) async {
    return await safeWriteJson(
      '$_courseProgressKey${progress.courseId}',
      progress,
      (p) => p.toJson(),
    );
  }

  static StorageResult<CourseProgress?> getCourseProgress(String courseId) {
    return safeReadJson<CourseProgress?>(
      '$_courseProgressKey$courseId',
      (json) => CourseProgress.fromJson(json),
      defaultValue: null,
    );
  }

  static Map<String, CourseProgress> getAllCourseProgress() {
    final Map<String, CourseProgress> progressMap = {};
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_courseProgressKey)) {
        final courseId = key.substring(_courseProgressKey.length);
        final result = getCourseProgress(courseId);
        if (result.isSuccess && result.value != null) {
          progressMap[courseId] = result.value!;
        }
      }
    }
    return progressMap;
  }

  static Future<StorageResult<void>> clearCourseProgress(
    String courseId,
  ) async {
    try {
      await prefs.remove('$_courseProgressKey$courseId');
      return StorageResult.success(null);
    } catch (e) {
      return StorageResult.failure(
        StorageError(
          'Failed to clear course progress',
          key: courseId,
          originalError: e,
        ),
      );
    }
  }

  // Preferences
  static Future<StorageResult<void>> savePreferences(
    UserPreferences preferences,
  ) async {
    return await safeWriteJson(_preferencesKey, preferences, (p) => p.toJson());
  }

  static StorageResult<UserPreferences> getPreferences() {
    return safeReadJson<UserPreferences>(
      _preferencesKey,
      (json) => UserPreferences.fromJson(json),
      defaultValue: UserPreferences(),
    );
  }

  // Downloads (for offline access)
  static Future<StorageResult<void>> saveDownloadedContent(
    String contentId,
    Map<String, dynamic> content,
  ) async {
    try {
      final downloads = getDownloadedContent();
      downloads[contentId] = content;
      await prefs.setString(_downloadsKey, jsonEncode(downloads));
      return StorageResult.success(null);
    } catch (e) {
      return StorageResult.failure(
        StorageError(
          'Failed to save download',
          key: contentId,
          originalError: e,
        ),
      );
    }
  }

  static Map<String, dynamic> getDownloadedContent() {
    final json = prefs.getString(_downloadsKey);
    if (json == null) return {};
    try {
      return Map<String, dynamic>.from(jsonDecode(json));
    } catch (_) {
      return {};
    }
  }

  static Future<StorageResult<void>> removeDownload(String contentId) async {
    try {
      final downloads = getDownloadedContent();
      downloads.remove(contentId);
      await prefs.setString(_downloadsKey, jsonEncode(downloads));
      return StorageResult.success(null);
    } catch (e) {
      return StorageResult.failure(
        StorageError(
          'Failed to remove download',
          key: contentId,
          originalError: e,
        ),
      );
    }
  }

  static Future<StorageResult<void>> clearDownloads() async {
    try {
      await prefs.remove(_downloadsKey);
      return StorageResult.success(null);
    } catch (e) {
      return StorageResult.failure(
        StorageError(
          'Failed to clear downloads',
          key: _downloadsKey,
          originalError: e,
        ),
      );
    }
  }

  // Daily Challenge
  static String _dateToString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static Future<StorageResult<void>> markDailyChallengeCompleted(
    DateTime date,
    int score,
  ) async {
    try {
      final dateKey = _dateToString(date);
      await prefs.setBool('$_dailyChallengeCompletionKey$dateKey', true);
      await prefs.setInt('$_dailyChallengeScoreKey$dateKey', score);
      return StorageResult.success(null);
    } catch (e) {
      final dateKey = _dateToString(date);
      return StorageResult.failure(
        StorageError(
          'Failed to mark daily challenge',
          key: dateKey,
          originalError: e,
        ),
      );
    }
  }

  static bool isDailyChallengeCompleted(DateTime date) {
    final dateKey = _dateToString(date);
    return prefs.getBool('$_dailyChallengeCompletionKey$dateKey') ?? false;
  }

  static int getDailyChallengeScore(DateTime date) {
    final dateKey = _dateToString(date);
    return prefs.getInt('$_dailyChallengeScoreKey$dateKey') ?? 0;
  }

  static String _activityKey(DateTime date) =>
      '$_activityPrefix${date.year}-${date.month}-${date.day}';

  static Future<void> markActivity(DateTime date) async {
    await prefs.setBool(_activityKey(date), true);
  }

  static List<bool> getActivityForWeek(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return List<bool>.generate(
      7,
      (index) =>
          prefs.getBool(_activityKey(monday.add(Duration(days: index)))) ??
          false,
    );
  }

  // Lesson Progress
  static String _lessonProgressKey(String courseId, String lessonId) =>
      '$_lessonProgressPrefix$courseId:$lessonId';

  static Future<StorageResult<void>> saveLessonProgress({
    required String courseId,
    required String lessonId,
    required int currentStepIndex,
    required Map<int, Object> answeredSteps,
    required Map<int, int> hintsUsed,
    required bool isFinished,
    required int contentVersion,
  }) async {
    try {
      final data = <String, dynamic>{
        'currentStepIndex': currentStepIndex,
        'answeredSteps': answeredSteps.map(
          (key, value) => MapEntry('$key', value),
        ),
        'hintsUsed': hintsUsed.map((key, value) => MapEntry('$key', value)),
        'isFinished': isFinished,
        'lastUpdated': _clock.now().toIso8601String(),
        'contentVersion': contentVersion,
      };
      await prefs.setString(
        _lessonProgressKey(courseId, lessonId),
        jsonEncode(data),
      );
      return StorageResult.success(null);
    } catch (e) {
      return StorageResult.failure(
        StorageError(
          'Failed to save lesson progress',
          key: '$courseId:$lessonId',
          originalError: e,
        ),
      );
    }
  }

  static StorageResult<LessonProgress?> loadLessonProgress(
    String courseId,
    String lessonId,
  ) {
    final dataString = prefs.getString(_lessonProgressKey(courseId, lessonId));
    if (dataString == null) return StorageResult.success(null);

    try {
      final data = jsonDecode(dataString) as Map<String, dynamic>;
      final answers = Map<String, dynamic>.from(
        data['answeredSteps'] as Map? ?? {},
      );
      final hints = Map<String, dynamic>.from(data['hintsUsed'] as Map? ?? {});
      return StorageResult.success(
        LessonProgress(
          currentStepIndex: data['currentStepIndex'] as int? ?? 0,
          answeredSteps: answers.map(
            (key, value) => MapEntry(int.parse(key), value),
          ),
          hintsUsed: hints.map(
            (key, value) => MapEntry(int.parse(key), value as int),
          ),
          isFinished: data['isFinished'] as bool? ?? false,
          contentVersion: data['contentVersion'] as int? ?? 1,
          lastUpdated: data['lastUpdated'] != null
              ? DateTime.tryParse(data['lastUpdated'] as String)
              : null,
        ),
      );
    } catch (e) {
      return StorageResult.failure(
        StorageError(
          'Failed to load lesson progress',
          key: '$courseId:$lessonId',
          originalError: e,
        ),
      );
    }
  }

  static Future<StorageResult<void>> clearLessonProgress(
    String courseId,
    String lessonId,
  ) async {
    try {
      await prefs.remove(_lessonProgressKey(courseId, lessonId));
      return StorageResult.success(null);
    } catch (e) {
      return StorageResult.failure(
        StorageError(
          'Failed to clear lesson progress',
          key: '$courseId:$lessonId',
          originalError: e,
        ),
      );
    }
  }

  // Last Sync
  static Future<StorageResult<void>> setLastSync(DateTime dateTime) async {
    try {
      await prefs.setString(_lastSyncKey, dateTime.toIso8601String());
      return StorageResult.success(null);
    } catch (e) {
      return StorageResult.failure(
        StorageError(
          'Failed to set last sync',
          key: _lastSyncKey,
          originalError: e,
        ),
      );
    }
  }

  static DateTime? getLastSync() {
    final str = prefs.getString(_lastSyncKey);
    if (str == null) return null;
    try {
      return DateTime.parse(str);
    } catch (_) {
      return null;
    }
  }

  // Generic helpers
  static Future<StorageResult<void>> setBool(String key, bool value) async {
    try {
      await prefs.setBool(key, value);
      return StorageResult.success(null);
    } catch (e) {
      return StorageResult.failure(
        StorageError('Failed to set bool', key: key, originalError: e),
      );
    }
  }

  static bool getBool(String key, {bool defaultValue = false}) {
    return prefs.getBool(key) ?? defaultValue;
  }

  static Future<StorageResult<void>> setInt(String key, int value) async {
    try {
      await prefs.setInt(key, value);
      return StorageResult.success(null);
    } catch (e) {
      return StorageResult.failure(
        StorageError('Failed to set int', key: key, originalError: e),
      );
    }
  }

  static int getInt(String key, {int defaultValue = 0}) {
    return prefs.getInt(key) ?? defaultValue;
  }

  static Future<StorageResult<void>> setString(String key, String value) async {
    try {
      await prefs.setString(key, value);
      return StorageResult.success(null);
    } catch (e) {
      return StorageResult.failure(
        StorageError('Failed to set string', key: key, originalError: e),
      );
    }
  }

  static String? getString(String key) {
    return prefs.getString(key);
  }

  static Future<StorageResult<void>> remove(String key) async {
    try {
      await prefs.remove(key);
      return StorageResult.success(null);
    } catch (e) {
      return StorageResult.failure(
        StorageError('Failed to remove key', key: key, originalError: e),
      );
    }
  }

  static Future<StorageResult<void>> clearAll() async {
    try {
      await prefs.clear();
      return StorageResult.success(null);
    } catch (e) {
      return StorageResult.failure(
        StorageError('Failed to clear all', originalError: e),
      );
    }
  }
}

class LocalPreferences {
  String? getString(String key) => LocalDatabaseService.read(key) as String?;
  int? getInt(String key) => LocalDatabaseService.read(key) as int?;
  bool? getBool(String key) => LocalDatabaseService.read(key) as bool?;
  List<String>? getStringList(String key) {
    final value = LocalDatabaseService.read(key);
    return value is List ? value.cast<String>() : null;
  }

  dynamic get(String key) => LocalDatabaseService.read(key);
  Set<String> getKeys() => LocalDatabaseService.keys;
  Future<bool> setString(String key, String value) async {
    await LocalDatabaseService.write(key, value);
    return true;
  }

  Future<bool> setInt(String key, int value) async {
    await LocalDatabaseService.write(key, value);
    return true;
  }

  Future<bool> setBool(String key, bool value) async {
    await LocalDatabaseService.write(key, value);
    return true;
  }

  Future<bool> setStringList(String key, List<String> value) async {
    await LocalDatabaseService.write(key, value);
    return true;
  }

  Future<bool> remove(String key) async {
    await LocalDatabaseService.remove(key);
    return true;
  }

  Future<bool> clear() async {
    await LocalDatabaseService.clear();
    return true;
  }
}

class LessonProgress {
  final int currentStepIndex;
  final Map<int, Object> answeredSteps;
  final Map<int, int> hintsUsed; // stepIndex -> hints used count
  final bool isFinished;
  final int contentVersion;
  final DateTime? lastUpdated;

  LessonProgress({
    required this.currentStepIndex,
    required this.answeredSteps,
    required this.hintsUsed,
    required this.isFinished,
    this.contentVersion = 1,
    this.lastUpdated,
  });
}
