import 'dart:async';

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

    final signature = _buildSignature(surahs);
    if (_indexedSignature == signature) {
      return;
    }

    final db = await _openDb();
    await db.transaction((txn) async {
      await txn.delete(_ftsTable);
      final batch = txn.batch();

      for (final surah in surahs) {
        final topics = _topicsForSurah(surah);
        for (final verse in surah.verses) {
          batch.insert(_ftsTable, <String, Object>{
            'surah_number': surah.number,
            'surah_name_ar': surah.nameAr,
            'surah_name_en': surah.nameEn,
            'verse_number': verse.number,
            'text_ar': verse.textAr,
            'topic_terms': topics,
          });
        }
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

    final db = await _openDb();
    final ftsQuery = _buildFtsQuery(normalized);
    if (ftsQuery.isEmpty) {
      return const <QuranSmartSearchMatch>[];
    }

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

    final bySurah = <int, QuranSmartSearchMatch>{};
    for (final row in rows) {
      final surahNumber = row['surah_number'] as int?;
      if (surahNumber == null || bySurah.containsKey(surahNumber)) {
        continue;
      }
      final previewRaw = (row['preview'] as String? ?? '').trim();
      bySurah[surahNumber] = QuranSmartSearchMatch(
        surahNumber: surahNumber,
        preview: previewRaw,
      );
      if (bySurah.length >= limit) {
        break;
      }
    }

    return bySurah.values.toList(growable: false);
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
    _db = db;
    return db;
  }

  static String _buildSignature(List<QuranSurah> surahs) {
    var versesCount = 0;
    for (final surah in surahs) {
      versesCount += surah.verses.length;
    }
    return '${surahs.length}:$versesCount';
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

  static String _topicsForSurah(QuranSurah surah) {
    final text = surah.verses.map((verse) => verse.textAr).join(' ');
    final tags = <String>[];

    for (final entry in _topicKeywords.entries) {
      final key = entry.key;
      final keywords = entry.value;
      final hasAny = keywords.any(text.contains);
      if (hasAny) {
        tags.add(key);
      }
    }

    return tags.join(' ');
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
