import 'dart:async';
import 'package:yusr_app/core/utils/app_logger.dart';
import 'package:yusr_app/features/quran/data/models/quran_models.dart';
import 'package:yusr_app/features/quran/data/search/quran_search_db_layer.dart';
import 'package:yusr_app/features/quran/data/search/quran_search_index_builder.dart';
import 'package:yusr_app/features/quran/data/search/quran_search_query_engine.dart';

class QuranSmartSearchService {
  QuranSmartSearchService({
    QuranSearchDbLayer? dbLayer,
    QuranSearchIndexBuilder? indexBuilder,
    QuranSearchQueryEngine? queryEngine,
  }) : _dbLayer = dbLayer ?? QuranSearchDbLayer(),
       _indexBuilder =
           indexBuilder ??
           QuranSearchIndexBuilder(dbLayer ?? QuranSearchDbLayer()),
       _queryEngine =
           queryEngine ??
           QuranSearchQueryEngine(dbLayer ?? QuranSearchDbLayer());

  final QuranSearchDbLayer _dbLayer;
  final QuranSearchIndexBuilder _indexBuilder;
  final QuranSearchQueryEngine _queryEngine;

  Future<void>? _indexing;
  bool _isEnabled = true;

  Future<void> ensureIndex(List<QuranSurah> surahs) async {
    if (!_isEnabled || surahs.isEmpty) return;

    if (_indexing != null) return _indexing;

    final task = _indexBuilder.buildIndex(surahs);
    _indexing = task;

    try {
      await task;
    } catch (error, stackTrace) {
      _disableSearch(
        reason: 'Failed to build Quran smart-search index; disabling search.',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      _indexing = null;
    }
  }

  Future<List<QuranSmartSearchMatch>> search(
    String query, {
    int limit = 60,
  }) async {
    if (!_isEnabled) return [];

    try {
      return await _queryEngine.executeSearch(query, limit: limit);
    } catch (error, stackTrace) {
      _disableSearch(
        reason: 'Quran smart-search query failed; disabling search.',
        error: error,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  void _disableSearch({
    required String reason,
    required Object error,
    required StackTrace stackTrace,
  }) {
    if (!_isEnabled) return;
    _isEnabled = false;
    AppLogger.error(
      'quran',
      'smartSearch',
      reason,
      error: error,
      stackTrace: stackTrace,
    );
  }

  Future<void> dispose() async {
    await _dbLayer.close();
  }
}
