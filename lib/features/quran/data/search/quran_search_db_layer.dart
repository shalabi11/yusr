import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:yusr_app/core/database/app_database.dart';
import 'package:yusr_app/core/utils/app_logger.dart';

class QuranSearchDbLayer implements DatabaseTable {
  static const String ftsTable = 'quran_verse_fts';
  static const String metaTable = 'quran_smart_search_meta';

  @override
  String get tableName => ftsTable;

  Future<Database> get database => AppDatabase.instance.database;

  @override
  Future<void> onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE IF NOT EXISTS $metaTable ('
      'key TEXT PRIMARY KEY, '
      'value TEXT NOT NULL'
      ')',
    );
    await _createFtsTable(db);
  }

  @override
  Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle migrations here if needed
  }

  Future<void> _createFtsTable(Database db) async {
    try {
      // Attempt FTS5 first
      await db.execute(
        'CREATE VIRTUAL TABLE IF NOT EXISTS $ftsTable USING fts5('
        'surah_number UNINDEXED, '
        'surah_name_ar, '
        'surah_name_en, '
        'verse_number UNINDEXED, '
        'text_ar, '
        'topic_terms'
        ')',
      );
    } catch (e) {
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('no such module: fts5')) {
        AppLogger.warning(
          'quran',
          'search_db',
          'FTS5 not supported, falling back to FTS4',
          error: e,
        );
        // Explicitly drop in case a broken FTS5 entry exists in sqlite_master
        await db.execute('DROP TABLE IF EXISTS $ftsTable');
        await db.execute(
          'CREATE VIRTUAL TABLE IF NOT EXISTS $ftsTable USING fts4('
          'surah_number, '
          'surah_name_ar, '
          'surah_name_en, '
          'verse_number, '
          'text_ar, '
          'topic_terms'
          ')',
        );
      } else {
        rethrow;
      }
    }
  }

  /// Drops and recreates the FTS table using FTS4.
  /// Called when the on-disk DB already has a broken FTS5 table (from an older
  /// app run on a device that doesn't support the fts5 SQLite module).
  Future<void> repairFtsTable(Database db) async {
    AppLogger.warning('quran', 'search_db', 'Repairing broken FTS table: dropping and recreating with FTS4');
    await db.execute('DROP TABLE IF EXISTS $ftsTable');
    await db.execute(
      'CREATE VIRTUAL TABLE IF NOT EXISTS $ftsTable USING fts4('
      'surah_number, '
      'surah_name_ar, '
      'surah_name_en, '
      'verse_number, '
      'text_ar, '
      'topic_terms'
      ')',
    );
    // Clear the cached signature so the index is fully rebuilt
    await db.delete(metaTable);
  }

  Future<void> close() => AppDatabase.instance.close();
}
