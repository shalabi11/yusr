import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
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

  Future<void> ensureIndex(List<QuranSurah> surahs) async {
    if (surahs.isEmpty) {
      return;
    }

    final indexPayload = await compute(_prepareIndexPayload, surahs);
    final signature = indexPayload['signature'] as String? ?? '';
    if (_indexedSignature == signature) {
      return;
    }

    final rows = (indexPayload['rows'] as List<Object?>?) ?? const <Object?>[];

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
  }

  Future<List<QuranSmartSearchMatch>> search(
    String query, {
    int limit = 60,
  }) async {
    final normalized = query.trim();
    if (normalized.isEmpty) {
      return const <QuranSmartSearchMatch>[];
    }

    final ftsQuery = await compute(_buildFtsQuery, normalized);
    if (ftsQuery.isEmpty) {
      return const <QuranSmartSearchMatch>[];
    }

    final db = await _openDb();

    final rows = await db.rawQuery(
      '''
      SELECT surah_number, verse_number,
             snippet($_ftsTable, 4, '', '', '…', 14) AS preview,
             bm25($_ftsTable) AS rank
      FROM $_ftsTable
      WHERE $_ftsTable MATCH ?
      ORDER BY rank
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
      'preview': (row['preview'] as String? ?? '').trim(),
    };
    if (bySurah.length >= limit) {
      break;
    }
  }

  return bySurah.values.toList(growable: false);
}
