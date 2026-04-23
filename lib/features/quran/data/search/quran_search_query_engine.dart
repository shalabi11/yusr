import 'package:flutter/foundation.dart';
import 'package:yusr_app/features/quran/data/search/quran_search_db_layer.dart';

class QuranSearchQueryEngine {
  final QuranSearchDbLayer _dbLayer;

  QuranSearchQueryEngine(this._dbLayer);

  Future<List<QuranSmartSearchMatch>> executeSearch(
    String query, {
    int limit = 60,
  }) async {
    final normalized = query.trim();
    if (normalized.isEmpty) return [];

    final ftsQuery = await compute(_buildFtsQuery, normalized);
    if (ftsQuery.isEmpty) return [];

    final db = await _dbLayer.database;

    // We group by surah_number to return unique surahs as per existing logic.
    final rows = await db.rawQuery(
      '''
      SELECT surah_number, MIN(text_ar) AS preview
      FROM ${QuranSearchDbLayer.ftsTable}
      WHERE ${QuranSearchDbLayer.ftsTable} MATCH ?
      GROUP BY surah_number
      ORDER BY rowid
      LIMIT ?
      ''',
      <Object>[ftsQuery, limit],
    );

    return rows
        .map(
          (row) => QuranSmartSearchMatch(
            surahNumber: (row['surah_number'] as int?) ?? 0,
            preview: _trimPreview((row['preview'] as String? ?? '').trim()),
          ),
        )
        .where((match) => match.surahNumber > 0)
        .toList(growable: false);
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
    if (tokens.isEmpty) return '';

    return tokens
        .map((token) => token.replaceAll('"', '').trim())
        .where((token) => token.isNotEmpty)
        .map((token) => '$token*')
        .join(' OR ');
  }

  static const Map<String, List<String>> _topicKeywords = {
    'prayer': ['صلاة', 'الصلاة', 'يسجدون', 'قيام'],
    'mercy': ['رحمة', 'رحيم', 'الغفور', 'غفور'],
    'patience': ['صبر', 'الصابرين', 'اصبر'],
    'charity': ['زكاة', 'صدقة', 'ينفقون', 'أنفقوا'],
    'paradise': ['جنة', 'جنات', 'الفردوس'],
    'fire': ['نار', 'جهنم', 'السعير'],
    'taqwa': ['تقوى', 'المتقين', 'اتقوا'],
    'dua': ['ادعوا', 'دعاء', 'ربنا', 'استجب'],
    'الصلاة': ['صلاة', 'الصلاة', 'يسجدون', 'قيام'],
    'الرحمة': ['رحمة', 'رحيم', 'الغفور', 'غفور'],
    'الصبر': ['صبر', 'الصابرين', 'اصبر'],
    'الصدقة': ['زكاة', 'صدقة', 'ينفقون', 'أنفقوا'],
    'الجنة': ['جنة', 'جنات', 'الفردوس'],
    'النار': ['نار', 'جهنم', 'السعير'],
    'التقوى': ['تقوى', 'المتقين', 'اتقوا'],
    'الدعاء': ['ادعوا', 'دعاء', 'ربنا', 'استجب'],
  };

  static Map<String, List<String>> get topicKeywords => _topicKeywords;

  static String _trimPreview(String value) {
    if (value.length <= 70) {
      return value;
    }
    return '${value.substring(0, 70)}...';
  }
}

class QuranSmartSearchMatch {
  const QuranSmartSearchMatch({
    required this.surahNumber,
    required this.preview,
  });

  final int surahNumber;
  final String preview;
}
