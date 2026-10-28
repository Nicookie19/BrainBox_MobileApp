import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class LocalDatabaseService {
  LocalDatabaseService._();
  static Database? _database;
  static final Map<String, String> _values = {};

  static Future<void> initialize() async {
    if (_database != null) return;
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    _database = await openDatabase('${await getDatabasesPath()}/brainbox.db',
        version: 1,
        onCreate: (db, _) => db.execute(
            'CREATE TABLE app_values (key TEXT PRIMARY KEY, value TEXT NOT NULL)'));
    final rows = await _database!.query('app_values');
    _values.addEntries(rows.map((row) =>
        MapEntry(row['key']! as String, row['value']! as String)));
    if (_values.isEmpty) {
      final legacy = await SharedPreferences.getInstance();
      for (final key in legacy.getKeys()) {
        final value = legacy.get(key);
        if (value != null) await write(key, value);
      }
    }
  }

  static dynamic read(String key) =>
      _values[key] == null ? null : jsonDecode(_values[key]!);
  static Future<void> write(String key, dynamic value) async {
    final encoded = jsonEncode(value);
    _values[key] = encoded;
    await _database!.insert('app_values', {'key': key, 'value': encoded},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
  static Future<void> remove(String key) async {
    _values.remove(key);
    await _database!.delete('app_values', where: 'key = ?', whereArgs: [key]);
  }
  static Future<void> clear() async {
    _values.clear();
    await _database!.delete('app_values');
  }
  static Set<String> get keys => _values.keys.toSet();
}
