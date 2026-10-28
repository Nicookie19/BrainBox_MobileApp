import 'package:shared_preferences/shared_preferences.dart';

/// Browser fallback: SQLite is not available in Flutter Web, so use the
/// browser's persistent preferences store behind the same local-only API.
class LocalDatabaseService {
  LocalDatabaseService._();
  static SharedPreferences? _preferences;

  static Future<void> initialize() async {
    _preferences ??= await SharedPreferences.getInstance();
  }
  static dynamic read(String key) => _preferences!.get(key);
  static Future<void> write(String key, dynamic value) async {
    if (value is String) await _preferences!.setString(key, value);
    if (value is int) await _preferences!.setInt(key, value);
    if (value is bool) await _preferences!.setBool(key, value);
    if (value is List<String>) await _preferences!.setStringList(key, value);
  }
  static Future<void> remove(String key) => _preferences!.remove(key);
  static Future<void> clear() => _preferences!.clear();
  static Set<String> get keys => _preferences!.getKeys();
}
