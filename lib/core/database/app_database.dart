import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'schema.dart';

/// Owns the single SQLite connection for the app.
///
/// Usage: `final db = await AppDatabase.instance.database;`
/// Tests open a separate database with [AppDatabase.open].
class AppDatabase {
  AppDatabase._({DatabaseFactory? factory, String? path})
      : _factory = factory,
        _path = path;

  /// Replaceable so tests can point the whole app at an in-memory database.
  static AppDatabase instance = AppDatabase._();

  /// Opens a database at [path] using [factory], for example an in-memory
  /// database in tests.
  factory AppDatabase.open({
    required DatabaseFactory factory,
    required String path,
  }) {
    return AppDatabase._(factory: factory, path: path);
  }

  static const _fileName = 'sirkular.db';

  final DatabaseFactory? _factory;
  final String? _path;
  Database? _database;

  /// Current time as ISO-8601 text, the format used by every timestamp column.
  static String now() => DateTime.now().toIso8601String();

  Future<Database> get database async {
    final existing = _database;
    if (existing != null) return existing;

    final factory = _factory ?? databaseFactory;
    final path = _path ?? p.join(await getDatabasesPath(), _fileName);
    final db = await factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: currentSchemaVersion,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: (db, _) => _runMigrations(db, 0, currentSchemaVersion),
        onUpgrade: (db, oldVersion, newVersion) =>
            _runMigrations(db, oldVersion, newVersion),
      ),
    );
    _database = db;
    return db;
  }

  /// Runs every migration after [from] up to and including [to], in order.
  static Future<void> _runMigrations(Database db, int from, int to) async {
    for (final migration in migrations) {
      if (migration.version <= from || migration.version > to) continue;
      for (final statement in migration.statements) {
        await db.execute(statement);
      }
    }
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
