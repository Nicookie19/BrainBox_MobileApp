import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

/// Persistence behind [StorageService].
///
/// Values are one of: [String], [bool], [int] or [List<String>]. Backends only
/// persist; [StorageService] keeps an in-memory copy so reads stay synchronous.
abstract class StorageBackend {
  /// Reads every stored entry.
  Future<Map<String, Object>> loadAll();

  Future<void> write(String key, Object value);

  Future<void> delete(String key);

  Future<void> clear();
}

/// Keeps everything in memory. Used by tests.
class MemoryStorageBackend implements StorageBackend {
  MemoryStorageBackend([Map<String, Object>? initial])
    : _data = {...?initial};

  final Map<String, Object> _data;

  @override
  Future<Map<String, Object>> loadAll() async => {..._data};

  @override
  Future<void> write(String key, Object value) async => _data[key] = value;

  @override
  Future<void> delete(String key) async => _data.remove(key);

  @override
  Future<void> clear() async => _data.clear();
}

/// SharedPreferences storage. Used on the web (where SQLite is unavailable) and
/// to read data written by older versions of the app.
class SharedPrefsBackend implements StorageBackend {
  SharedPreferences? _prefs;

  Future<SharedPreferences> _instance() async =>
      _prefs ??= await SharedPreferences.getInstance();

  @override
  Future<Map<String, Object>> loadAll() async {
    final prefs = await _instance();
    final result = <String, Object>{};
    for (final key in prefs.getKeys()) {
      final value = prefs.get(key);
      if (value is String || value is bool || value is int) {
        result[key] = value!;
      } else if (value is List) {
        result[key] = List<String>.from(value);
      }
    }
    return result;
  }

  @override
  Future<void> write(String key, Object value) async {
    final prefs = await _instance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is List<String>) {
      await prefs.setStringList(key, value);
    } else {
      await prefs.setString(key, value.toString());
    }
  }

  @override
  Future<void> delete(String key) async {
    final prefs = await _instance();
    await prefs.remove(key);
  }

  @override
  Future<void> clear() async {
    final prefs = await _instance();
    await prefs.clear();
  }
}

/// SQLite storage (`brainbox.db`) for Android, iOS and desktop.
///
/// Schema (version 1):
///
/// ```sql
/// CREATE TABLE kv_store (
///   key        TEXT PRIMARY KEY NOT NULL,
///   type       TEXT NOT NULL,   -- 'string' | 'bool' | 'int' | 'list'
///   value      TEXT NOT NULL,
///   updated_at TEXT NOT NULL    -- UTC ISO-8601
/// );
/// ```
class SqliteBackend implements StorageBackend {
  /// [path] and [factory] exist so tests can open an in-memory database.
  SqliteBackend({this.path, this._factory});

  static const int schemaVersion = 1;
  static const String table = 'kv_store';
  static const String fileName = 'brainbox.db';

  final String? path;
  final DatabaseFactory? _factory;
  Database? _db;

  Future<Database> _open() async {
    final existing = _db;
    if (existing != null) return existing;

    final factory = _factory ?? databaseFactory;
    final dbPath =
        path ?? p.join(await factory.getDatabasesPath(), fileName);
    final db = await factory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: schemaVersion,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE $table (
              key TEXT PRIMARY KEY NOT NULL,
              type TEXT NOT NULL,
              value TEXT NOT NULL,
              updated_at TEXT NOT NULL
            )
          ''');
        },
      ),
    );
    _db = db;
    return db;
  }

  @override
  Future<Map<String, Object>> loadAll() async {
    final db = await _open();
    final rows = await db.query(table);
    final result = <String, Object>{};
    for (final row in rows) {
      final key = row['key'] as String;
      final type = row['type'] as String;
      final raw = row['value'] as String;
      switch (type) {
        case 'bool':
          result[key] = raw == '1';
        case 'int':
          final parsed = int.tryParse(raw);
          if (parsed != null) result[key] = parsed;
        case 'list':
          try {
            result[key] = List<String>.from(jsonDecode(raw) as List);
          } catch (_) {
            // Skip a corrupted row rather than failing app start-up.
          }
        default:
          result[key] = raw;
      }
    }
    return result;
  }

  @override
  Future<void> write(String key, Object value) async {
    final db = await _open();
    late final String type;
    late final String raw;
    if (value is bool) {
      type = 'bool';
      raw = value ? '1' : '0';
    } else if (value is int) {
      type = 'int';
      raw = '$value';
    } else if (value is List<String>) {
      type = 'list';
      raw = jsonEncode(value);
    } else {
      type = 'string';
      raw = value.toString();
    }
    await db.insert(table, {
      'key': key,
      'type': type,
      'value': raw,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> delete(String key) async {
    final db = await _open();
    await db.delete(table, where: 'key = ?', whereArgs: [key]);
  }

  @override
  Future<void> clear() async {
    final db = await _open();
    await db.delete(table);
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
