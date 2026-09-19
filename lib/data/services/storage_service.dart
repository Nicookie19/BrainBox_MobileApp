import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_models.dart';

class StorageService {
  static const String _userProfileKey = 'user_profile';
  static const String _courseProgressKey = 'course_progress_';
  static const String _preferencesKey = 'user_preferences';
  static const String _bookmarksKey = 'bookmarks';
  static const String _downloadsKey = 'downloads';
  static const String _streakKey = 'streak_data';
  static const String _lastSyncKey = 'last_sync';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static void resetForTesting() {
    _prefs = null;
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw StateError('StorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // User Profile
  static Future<void> saveUserProfile(UserProfile profile) async {
    final json = jsonEncode(profile.toJson());
    await prefs.setString(_userProfileKey, json);
  }

  static UserProfile? getUserProfile() {
    final json = prefs.getString(_userProfileKey);
    if (json == null) return null;
    try {
      return UserProfile.fromJson(jsonDecode(json));
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearUserProfile() async {
    await prefs.remove(_userProfileKey);
  }

  // Course Progress
  static Future<void> saveCourseProgress(CourseProgress progress) async {
    final json = jsonEncode(progress.toJson());
    await prefs.setString('$_courseProgressKey${progress.courseId}', json);
  }

  static CourseProgress? getCourseProgress(String courseId) {
    final json = prefs.getString('$_courseProgressKey$courseId');
    if (json == null) return null;
    try {
      return CourseProgress.fromJson(jsonDecode(json));
    } catch (_) {
      return null;
    }
  }

  static Map<String, CourseProgress> getAllCourseProgress() {
    final Map<String, CourseProgress> progressMap = {};
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_courseProgressKey)) {
        final courseId = key.substring(_courseProgressKey.length);
        final json = prefs.getString(key);
        if (json != null) {
          try {
            final progress = CourseProgress.fromJson(jsonDecode(json));
            progressMap[courseId] = progress;
          } catch (e) {
            // Skip corrupted data
          }
        }
      }
    }
    return progressMap;
  }

  static Future<void> clearCourseProgress(String courseId) async {
    await prefs.remove('$_courseProgressKey$courseId');
  }

  // Preferences
  static Future<void> savePreferences(UserPreferences preferences) async {
    final json = jsonEncode(preferences.toJson());
    await prefs.setString(_preferencesKey, json);
  }

  static UserPreferences getPreferences() {
    final json = prefs.getString(_preferencesKey);
    if (json == null) return UserPreferences();
    try {
      return UserPreferences.fromJson(jsonDecode(json));
    } catch (_) {
      return UserPreferences();
    }
  }

  // Bookmarks
  static Future<void> saveBookmarks(List<String> lessonIds) async {
    await prefs.setStringList(_bookmarksKey, lessonIds);
  }

  static List<String> getBookmarks() {
    return prefs.getStringList(_bookmarksKey) ?? [];
  }

  static Future<void> addBookmark(String lessonId) async {
    final bookmarks = getBookmarks();
    if (!bookmarks.contains(lessonId)) {
      bookmarks.add(lessonId);
      await saveBookmarks(bookmarks);
    }
  }

  static Future<void> removeBookmark(String lessonId) async {
    final bookmarks = getBookmarks();
    bookmarks.remove(lessonId);
    await saveBookmarks(bookmarks);
  }

  // Downloads (for offline access)
  static Future<void> saveDownloadedContent(
    String contentId,
    Map<String, dynamic> content,
  ) async {
    final downloads = getDownloadedContent();
    downloads[contentId] = content;
    await prefs.setString(_downloadsKey, jsonEncode(downloads));
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

  static Future<void> removeDownload(String contentId) async {
    final downloads = getDownloadedContent();
    downloads.remove(contentId);
    await prefs.setString(_downloadsKey, jsonEncode(downloads));
  }

  static Future<void> clearDownloads() async {
    await prefs.remove(_downloadsKey);
  }

  // Streak Data
  static Future<void> saveStreakData({
    required int currentStreak,
    required int longestStreak,
    required DateTime lastStudyDate,
  }) async {
    await prefs.setInt('${_streakKey}_current', currentStreak);
    await prefs.setInt('${_streakKey}_longest', longestStreak);
    await prefs.setString(
      '${_streakKey}_last_date',
      lastStudyDate.toIso8601String(),
    );
  }

  static ({int currentStreak, int longestStreak, DateTime? lastStudyDate})
  getStreakData() {
    final current = prefs.getInt('${_streakKey}_current') ?? 0;
    final longest = prefs.getInt('${_streakKey}_longest') ?? 0;
    final lastDateStr = prefs.getString('${_streakKey}_last_date');
    DateTime? lastDate;
    if (lastDateStr != null) {
      try {
        lastDate = DateTime.parse(lastDateStr);
      } catch (_) {
        lastDate = null;
      }
    }
    return (
      currentStreak: current,
      longestStreak: longest,
      lastStudyDate: lastDate,
    );
  }

  // Last Sync
  static Future<void> setLastSync(DateTime dateTime) async {
    await prefs.setString(_lastSyncKey, dateTime.toIso8601String());
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
  static Future<void> setBool(String key, bool value) async {
    await prefs.setBool(key, value);
  }

  static bool getBool(String key, {bool defaultValue = false}) {
    return prefs.getBool(key) ?? defaultValue;
  }

  static Future<void> setInt(String key, int value) async {
    await prefs.setInt(key, value);
  }

  static int getInt(String key, {int defaultValue = 0}) {
    return prefs.getInt(key) ?? defaultValue;
  }

  static Future<void> setString(String key, String value) async {
    await prefs.setString(key, value);
  }

  static String? getString(String key) {
    return prefs.getString(key);
  }

  static Future<void> remove(String key) async {
    await prefs.remove(key);
  }

  static Future<void> clearAll() async {
    await prefs.clear();
  }
}
