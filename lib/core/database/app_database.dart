import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

abstract class DatabaseTable {
  String get tableName;
  Future<void> onCreate(Database db, int version);
  Future<void> onUpgrade(Database db, int oldVersion, int newVersion);
}

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  static const String _dbName = 'yusr_main.db';
  static const int _dbVersion = 1;

  Database? _db;
  Future<Database>? _dbOpening;
  final List<DatabaseTable> _tables = [];

  void registerTable(DatabaseTable table) {
    _tables.add(table);
  }

  Future<Database> get database async {
    if (_db != null) return _db!;
    if (_dbOpening != null) return _dbOpening!;

    _dbOpening = _openDbInternal();
    try {
      _db = await _dbOpening;
      return _db!;
    } finally {
      _dbOpening = null;
    }
  }

  Future<Database> _openDbInternal() async {
    final dir = await getApplicationSupportDirectory();
    final path = p.join(dir.path, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onConfigure: (db) async {
        await db.rawQuery('PRAGMA page_size = 4096');
        await db.rawQuery('PRAGMA auto_vacuum = INCREMENTAL');
        await db.rawQuery('PRAGMA journal_mode = WAL');
        await db.rawQuery('PRAGMA synchronous = NORMAL');
      },
      onCreate: (db, version) async {
        for (final table in _tables) {
          await table.onCreate(db, version);
        }
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        for (final table in _tables) {
          await table.onUpgrade(db, oldVersion, newVersion);
        }
      },
    );
  }

  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
