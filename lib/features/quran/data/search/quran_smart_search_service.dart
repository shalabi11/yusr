import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:yusr_app/core/utils/app_logger.dart';
import 'package:yusr_app/features/quran/data/models/quran_models.dart';

class QuranSmartSearchMatch {
  const QuranSmartSearchMatch({
    required this.surahNumber,
    required this.preview,
  });

  final int surahNumber;
  final String preview;
}

class QuranSmartSearchService {
  static const String _dbName = 'quran_smart_search.db';
  static const String _ftsTable = 'quran_verse_fts';

  Database? _db;
  String? _indexedSignature;
  bool _isEnabled = true;

  Future<void> ensureIndex(List<QuranSurah> surahs) async {
    if (!_isEnabled || surahs.isEmpty) {
      return;
    }

    try {
      final indexPayload = await compute(_prepareIndexPayload, surahs);
      final signature = indexPayload['signature'] as String? ?? '';
      if (_indexedSignature == signature) {
        return;
      }

      final rows =
          (indexPayload['rows'] as List<Object?>?) ?? const <Object?>[];

      final db = await _openDb();
      await db.transaction((txn) async {
        await txn.delete(_ftsTable);
        final batch = txn.batch();

        for (final row in rows) {
          batch.insert(
            _ftsTable,
            Map<String, Object?>.from(row as Map<Object?, Object?>),
          );
        }

        await batch.commit(noResult: true);
      });

      _indexedSignature = signature;
    } catch (error, stackTrace) {
      _disableSearch(
        reason: 'Failed to build Quran smart-search index; disabling search.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<List<QuranSmartSearchMatch>> search(
    String query, {
    int limit = 60,
  }) async {
    if (!_isEnabled) {
      return const <QuranSmartSearchMatch>[];
    }

    final normalized = query.trim();
    if (normalized.isEmpty) {
      return const <QuranSmartSearchMatch>[];
    }

    final ftsQuery = await compute(_buildFtsQuery, normalized);
    if (ftsQuery.isEmpty) {
      return const <QuranSmartSearchMatch>[];
    }

    try {
      final db = await _openDb();

      final rows = await db.rawQuery(
        '''
        SELECT surah_number, verse_number, text_ar AS preview
        FROM $_ftsTable
        WHERE $_ftsTable MATCH ?
        ORDER BY rowid
        LIMIT ?
        ''',
        <Object>[ftsQuery, limit * 4],
      );

      final reducedRows = await compute(_reduceSearchRows, <String, Object?>{
        'rows': rows,
        'limit': limit,
      });

      return reducedRows
          .map(
            (row) => QuranSmartSearchMatch(
              surahNumber: (row['surah_number'] as int?) ?? 0,
              preview: (row['preview'] as String? ?? '').trim(),
            ),
          )
          .where((match) => match.surahNumber > 0)
          .toList(growable: false);
    } catch (error, stackTrace) {
      _disableSearch(
        reason: 'Quran smart-search query failed; disabling search.',
        error: error,
        stackTrace: stackTrace,
      );
      return const <QuranSmartSearchMatch>[];
    }
  }

  Future<Database> _openDb() async {
    final current = _db;
    if (current != null) {
      return current;
    }

    final dir = await getApplicationSupportDirectory();
    final path = p.join(dir.path, _dbName);
    final db = await openDatabase(
      path,
      version: 1,
      onCreate: (database, _) async {
        await database.execute('PRAGMA page_size = 4096');
        await database.execute('PRAGMA auto_vacuum = INCREMENTAL');
        await _createFtsTable(database);
      },
    );
    await db.execute('PRAGMA journal_mode = WAL');
    await db.execute('PRAGMA synchronous = NORMAL');
    await db.execute('PRAGMA temp_store = MEMORY');
    await db.execute('PRAGMA cache_size = -8192');
    await db.execute('PRAGMA optimize');
    _db = db;
    return db;
  }

  Future<void> _createFtsTable(Database database) async {
    try {
      await database.execute(
        'CREATE VIRTUAL TABLE $_ftsTable USING fts5('
        'surah_number UNINDEXED, '
        'surah_name_ar, '
        'surah_name_en, '
        'verse_number UNINDEXED, '
        'text_ar, '
        'topic_terms'
        ')',
      );
    } on DatabaseException catch (error) {
      if (!_isFts5Unsupported(error)) {
        rethrow;
      }
      await database.execute(
        'CREATE VIRTUAL TABLE $_ftsTable USING fts4('
        'surah_number, '
        'surah_name_ar, '
        'surah_name_en, '
        'verse_number, '
        'text_ar, '
        'topic_terms'
        ')',
      );
    }
  }

  bool _isFts5Unsupported(DatabaseException error) {
    final message = error.toString().toLowerCase();
    return message.contains('no such module: fts5');
  }

  void _disableSearch({
    required String reason,
    required Object error,
    required StackTrace stackTrace,
  }) {
    if (!_isEnabled) {
      return;
    }
    _isEnabled = false;
    AppLogger.warning('quran', 'smartSearch', reason, error: error);
    AppLogger.error(
      'quran',
      'smartSearch',
      'Smart search disabled due to runtime failure.',
      error: error,
      stackTrace: stackTrace,
    );
  }

  static String _buildFtsQuery(String query) {
    final lower = query.toLowerCase();

    if (lower.startsWith('topic:')) {
      final topicKey = lower.substring(6).trim();
      final topicTokens = _topicKeywords[topicKey] ?? const <String>[];
      return _tokensToFts(topicTokens);
    }

    final topicTokens = _topicKeywords[lower];
    if (topicTokens != null) {
      return _tokensToFts(topicTokens);
    }

    final terms = query
        .split(RegExp(r'[^\w\u0600-\u06FF]+'))
        .map((item) => item.trim())
        .where((item) => item.length > 1)
        .toSet()
        .toList(growable: false);

    return _tokensToFts(terms);
  }

  static String _tokensToFts(List<String> tokens) {
    if (tokens.isEmpty) {
      return '';
    }

    return tokens
        .map((token) => token.replaceAll('"', '').trim())
        .where((token) => token.isNotEmpty)
        .map((token) => '$token*')
        .join(' OR ');
  }

  static const Map<String, List<String>> _topicKeywords =
      <String, List<String>>{
        'prayer': <String>['صلاة', 'الصلاة', 'يسجدون', 'قيام'],
        'mercy': <String>['رحمة', 'رحيم', 'الغفور', 'غفور'],
        'patience': <String>['صبر', 'الصابرين', 'اصبر'],
        'charity': <String>['زكاة', 'صدقة', 'ينفقون', 'أنفقوا'],
        'paradise': <String>['جنة', 'جنات', 'الفردوس'],
        'fire': <String>['نار', 'جهنم', 'السعير'],
        'taqwa': <String>['تقوى', 'المتقين', 'اتقوا'],
        'dua': <String>['ادعوا', 'دعاء', 'ربنا', 'استجب'],
        'الصلاة': <String>['صلاة', 'الصلاة', 'يسجدون', 'قيام'],
        'الرحمة': <String>['رحمة', 'رحيم', 'الغفور', 'غفور'],
        'الصبر': <String>['صبر', 'الصابرين', 'اصبر'],
        'الصدقة': <String>['زكاة', 'صدقة', 'ينفقون', 'أنفقوا'],
        'الجنة': <String>['جنة', 'جنات', 'الفردوس'],
        'النار': <String>['نار', 'جهنم', 'السعير'],
        'التقوى': <String>['تقوى', 'المتقين', 'اتقوا'],
        'الدعاء': <String>['ادعوا', 'دعاء', 'ربنا', 'استجب'],
      };
}

Map<String, Object?> _prepareIndexPayload(List<QuranSurah> surahs) {
  var versesCount = 0;
  final rows = <Map<String, Object?>>[];

  for (final surah in surahs) {
    final topics = _topicsForSurahInIsolate(surah);
    for (final verse in surah.verses) {
      versesCount += 1;
      rows.add(<String, Object?>{
        'surah_number': surah.number,
        'surah_name_ar': surah.nameAr,
        'surah_name_en': surah.nameEn,
        'verse_number': verse.number,
        'text_ar': verse.textAr,
        'topic_terms': topics,
      });
    }
  }

  return <String, Object?>{
    'signature': '${surahs.length}:$versesCount',
    'rows': rows,
  };
}

String _topicsForSurahInIsolate(QuranSurah surah) {
  final text = surah.verses.map((verse) => verse.textAr).join(' ');
  final tags = <String>[];

  for (final entry in QuranSmartSearchService._topicKeywords.entries) {
    final key = entry.key;
    final keywords = entry.value;
    final hasAny = keywords.any(text.contains);
    if (hasAny) {
      tags.add(key);
    }
  }

  return tags.join(' ');
}

List<Map<String, Object?>> _reduceSearchRows(Map<String, Object?> payload) {
  final rows = (payload['rows'] as List<Object?>?) ?? const <Object?>[];
  final limit = (payload['limit'] as int?) ?? 60;

  final bySurah = <int, Map<String, Object?>>{};
  for (final rowValue in rows) {
    final row = Map<Object?, Object?>.from(rowValue as Map<Object?, Object?>);
    final surahNumber = row['surah_number'] as int?;
    if (surahNumber == null || bySurah.containsKey(surahNumber)) {
      continue;
    }
    bySurah[surahNumber] = <String, Object?>{
      'surah_number': surahNumber,
      'preview': _trimPreview((row['preview'] as String? ?? '').trim()),
    };
    if (bySurah.length >= limit) {
      break;
    }
  }

  return bySurah.values.toList(growable: false);
}

String _trimPreview(String value) {
  if (value.length <= 70) {
    return value;
  }
  return '${value.substring(0, 70)}...';
}
