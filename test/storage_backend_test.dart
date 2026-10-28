import 'package:brainbox/data/services/storage_backend.dart';
import 'package:brainbox/data/services/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  SqliteBackend newDb() => SqliteBackend(
    path: inMemoryDatabasePath,
    factory: databaseFactoryFfi,
  );

  test('SQLite backend round-trips every value type', () async {
    final backend = newDb();
    await backend.write('s', 'hello');
    await backend.write('b', true);
    await backend.write('i', 42);
    await backend.write('l', ['a', 'b']);

    final loaded = await backend.loadAll();
    expect(loaded['s'], 'hello');
    expect(loaded['b'], true);
    expect(loaded['i'], 42);
    expect(loaded['l'], ['a', 'b']);
    await backend.close();
  });

  test('SQLite backend overwrites, deletes and clears', () async {
    final backend = newDb();
    await backend.write('k', 'one');
    await backend.write('k', 'two');
    expect((await backend.loadAll())['k'], 'two');

    await backend.delete('k');
    expect((await backend.loadAll()).containsKey('k'), isFalse);

    await backend.write('a', 1);
    await backend.write('b', 2);
    await backend.clear();
    expect(await backend.loadAll(), isEmpty);
    await backend.close();
  });

  test('StorageService persists through a SQLite backend', () async {
    final backend = newDb();
    StorageService.resetForTesting();
    await StorageService.init(backend: backend);

    await StorageService.setString('name', 'BrainBox');
    await StorageService.setBool('flag', true);
    await StorageService.setInt('count', 7);
    await StorageService.setStringList('days', ['2026-10-27']);

    // Reload from the database, as happens on the next app launch.
    StorageService.resetForTesting();
    await StorageService.init(backend: backend);

    expect(StorageService.getString('name'), 'BrainBox');
    expect(StorageService.getBool('flag'), isTrue);
    expect(StorageService.getInt('count'), 7);
    expect(StorageService.getStringList('days'), ['2026-10-27']);

    await StorageService.clearAll();
    expect(StorageService.getString('name'), isNull);
    await backend.close();
  });
}
