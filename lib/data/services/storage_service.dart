import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;

import '../models/user_models.dart';
import 'storage_backend.dart';

/// Synchronous key-value facade over a [StorageBackend].
///
/// On Android, iOS and desktop the data lives in a SQLite database; on the web
/// it falls back to SharedPreferences. Everything is loaded into memory at
/// start-up so reads are synchronous, and every write is saved to the backend
/// before its future completes.
class StorageService {
  static const String _userProfileKey = 'user_profile';
  static const String _courseProgressKey = 'course_progress_';
  static const String _preferencesKey = 'user_preferences';
  static const String _downloadsKey = 'downloads';

  static StorageBackend? _backend;
  static Map<String, Object> _data = {};

  /// Opens storage. Pass [backend] in tests (for example
  /// [MemoryStorageBackend]); by default SQLite is used, or SharedPreferences
  /// on the web.
  static Future<void> init({StorageBackend? backend}) async {
    final useDefault = backend == null;
    final chosen = backend ?? (kIsWeb ? SharedPrefsBackend() : SqliteBackend());
    final loaded = await chosen.loadAll();

    // One-time upgrade: older versions kept data in SharedPreferences. Copy it
    // into SQLite, then clear it so a later reset cannot bring it back.
    if (useDefault && !kIsWeb && loaded.isEmpty) {
      final legacy = SharedPrefsBackend();
      final old = await legacy.loadAll();
      if (old.isNotEmpty) {
        for (final entry in old.entries) {
          await chosen.write(entry.key, entry.value);
          loaded[entry.key] = entry.value;
        }
        await legacy.clear();
      }
    }

    _backend = chosen;
    _data = loaded;
  }

  static void resetForTesting() {
    _backend = null;
    _data = {};
  }

  static StorageBackend get _store {
    final backend = _backend;
    if (backend == null) {
      throw StateError('StorageService not initialized. Call init() first.');
    }
    return backend;
  }

  static Future<void> _put(String key, Object value) async {
    final store = _store;
    _data[key] = value;
    await store.write(key, value);
  }

  static Object? _get(String key) {
    _store; // throws if init() was never called
    return _data[key];
  }

  // User Profile
  static Future<void> saveUserProfile(UserProfile profile) async {
    await _put(_userProfileKey, jsonEncode(profile.toJson()));
  }

  static UserProfile? getUserProfile() {
    final json = getString(_userProfileKey);
    if (json == null) return null;
    try {
      return UserProfile.fromJson(jsonDecode(json));
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearUserProfile() async {
    await remove(_userProfileKey);
  }

  // Course Progress
  static Future<void> saveCourseProgress(CourseProgress progress) async {
    await _put(
      '$_courseProgressKey${progress.courseId}',
      jsonEncode(progress.toJson()),
    );
  }

  static CourseProgress? getCourseProgress(String courseId) {
    final json = getString('$_courseProgressKey$courseId');
    if (json == null) return null;
    try {
      return CourseProgress.fromJson(jsonDecode(json));
    } catch (_) {
      return null;
    }
  }

  static Map<String, CourseProgress> getAllCourseProgress() {
    final Map<String, CourseProgress> progressMap = {};
    _store;
    for (final key in _data.keys) {
      if (key.startsWith(_courseProgressKey)) {
        final courseId = key.substring(_courseProgressKey.length);
        final json = getString(key);
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
    await remove('$_courseProgressKey$courseId');
  }

  // Preferences
  static Future<void> savePreferences(UserPreferences preferences) async {
    await _put(_preferencesKey, jsonEncode(preferences.toJson()));
  }

  static UserPreferences getPreferences() {
    final json = getString(_preferencesKey);
    if (json == null) return UserPreferences();
    try {
      return UserPreferences.fromJson(jsonDecode(json));
    } catch (_) {
      return UserPreferences();
    }
  }

  // Downloads (for offline access)
  static Future<void> saveDownloadedContent(
    String contentId,
    Map<String, dynamic> content,
  ) async {
    final downloads = getDownloadedContent();
    downloads[contentId] = content;
    await _put(_downloadsKey, jsonEncode(downloads));
  }

  static Map<String, dynamic> getDownloadedContent() {
    final json = getString(_downloadsKey);
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
    await _put(_downloadsKey, jsonEncode(downloads));
  }

  static Future<void> clearDownloads() async {
    await remove(_downloadsKey);
  }

  // Generic helpers
  static Future<void> setBool(String key, bool value) async {
    await _put(key, value);
  }

  static bool getBool(String key, {bool defaultValue = false}) {
    final value = _get(key);
    return value is bool ? value : defaultValue;
  }

  static Future<void> setInt(String key, int value) async {
    await _put(key, value);
  }

  static int getInt(String key, {int defaultValue = 0}) {
    final value = _get(key);
    return value is int ? value : defaultValue;
  }

  static Future<void> setString(String key, String value) async {
    await _put(key, value);
  }

  static String? getString(String key) {
    final value = _get(key);
    return value is String ? value : null;
  }

  static List<String> getStringList(String key) {
    final value = _get(key);
    return value is List<String> ? List<String>.from(value) : <String>[];
  }

  static Future<void> setStringList(String key, List<String> value) async {
    await _put(key, List<String>.from(value));
  }

  static Future<void> remove(String key) async {
    final store = _store;
    _data.remove(key);
    await store.delete(key);
  }

  static Future<void> clearAll() async {
    final store = _store;
    _data.clear();
    await store.clear();
  }
}
