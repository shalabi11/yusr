import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:yusr_app/features/quran/data/models/quran_models.dart';
import 'package:yusr_app/features/quran/data/search/quran_search_db_layer.dart';
import 'package:yusr_app/features/quran/data/search/quran_search_query_engine.dart';

class QuranSearchIndexBuilder {
  final QuranSearchDbLayer _dbLayer;
  static const String _indexedSignatureMetaKey = 'indexed_signature';

  QuranSearchIndexBuilder(this._dbLayer);

  Future<void> buildIndex(List<QuranSurah> surahs) async {
    final db = await _dbLayer.database;

    final signature = _buildDatasetSignature(surahs);
    final existingSignature = await _readMetaValue(db, _indexedSignatureMetaKey);

    if (signature == existingSignature) return;

    final indexPayload = await compute(_prepareIndexPayload, {
      'surahs': surahs,
      'topicKeywords': QuranSearchQueryEngine.topicKeywords,
    });

    final rows = indexPayload['rows'] as List<Map<String, Object?>>;

    try {
      await _doIndexTransaction(db, rows, signature);
    } catch (e) {
      // If the FTS module is wrong (e.g. an fts5 table exists on a device that
      // only supports fts4), the on-disk table is broken. Heal it by dropping
      // and recreating with fts4, then retry once.
      if (e.toString().toLowerCase().contains('no such module: fts5')) {
        await _dbLayer.repairFtsTable(db);
        await _doIndexTransaction(db, rows, signature);
      } else {
        rethrow;
      }
    }
  }

  Future<void> _doIndexTransaction(
    Database db,
    List<Map<String, Object?>> rows,
    String signature,
  ) async {
    await db.transaction((txn) async {
      await txn.delete(QuranSearchDbLayer.ftsTable);
      final batch = txn.batch();
      for (final row in rows) {
        batch.insert(QuranSearchDbLayer.ftsTable, row);
      }
      await batch.commit(noResult: true);
      await txn.insert(
        QuranSearchDbLayer.metaTable,
        {'key': _indexedSignatureMetaKey, 'value': signature},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  static String _buildDatasetSignature(List<QuranSurah> surahs) {
    var verseCount = 0;
    var textLengthChecksum = 0;

    for (final surah in surahs) {
      for (final verse in surah.verses) {
        verseCount += 1;
        textLengthChecksum += verse.textAr.length;
      }
    }
    return '${surahs.length}:$verseCount:$textLengthChecksum';
  }

  Future<String?> _readMetaValue(Database db, String key) async {
    final rows = await db.query(
      QuranSearchDbLayer.metaTable,
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['value'] as String?;
  }
}

Map<String, Object?> _prepareIndexPayload(Map<String, Object?> data) {
  final surahs = data['surahs'] as List<QuranSurah>;
  final topicKeywords = data['topicKeywords'] as Map<String, List<String>>;

  final rows = <Map<String, Object?>>[];

  for (final surah in surahs) {
    final topics = _topicsForSurahInIsolate(surah, topicKeywords);
    for (final verse in surah.verses) {
      rows.add({
        'surah_number': surah.number,
        'surah_name_ar': surah.nameAr,
        'surah_name_en': surah.nameEn,
        'verse_number': verse.number,
        'text_ar': verse.textAr,
        'topic_terms': topics,
      });
    }
  }

  return {'rows': rows};
}

String _topicsForSurahInIsolate(QuranSurah surah, Map<String, List<String>> topicKeywords) {
  final text = surah.verses.map((verse) => verse.textAr).join(' ');
  final tags = <String>[];

  for (final entry in topicKeywords.entries) {
    if (entry.value.any(text.contains)) {
      tags.add(entry.key);
    }
  }
  return tags.join(' ');
}
