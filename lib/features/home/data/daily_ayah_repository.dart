import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'daily_ayah_model.dart';
import 'daily_ayah_remote_data_source.dart';

export 'daily_ayah_model.dart';

class DailyAyahRepository {
  DailyAyahRepository({DailyAyahRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  static List<DailyAyah>? _cache;
  final DailyAyahRemoteDataSource? _remoteDataSource;

  static const List<String> _themes = [
    'الصلاة',
    'آخرة',
    'الصبر',
    'الجنة',
    'النار',
    'التقوى',
    'الذكر',
  ];

  Future<List<DailyAyah>> _loadAyat() async {
    if (_cache != null) return _cache!;

    final remote = await _loadRemoteAyat();
    if (remote.isNotEmpty) {
      _cache = remote;
      return _cache!;
    }

    return _loadLocalAyat();
  }

  Future<List<DailyAyah>> _loadRemoteAyat() async {
    try {
      return await _remoteDataSource?.loadDailyAyat() ?? const [];
    } catch (_) {
      return const [];
    }
  }

  Future<List<DailyAyah>> _loadLocalAyat() async {
    final raw = await rootBundle.loadString('assets/data/mainDataQuran.json');
    _cache = await compute(
      _parseLocalAyat,
      _DailyAyahParseInput(raw: raw, themes: _themes),
    );
    return _cache!;
  }

  Future<DailyAyah> getDailyAyah() async {
    final ayat = await _loadAyat();
    if (ayat.isEmpty) {
      return const DailyAyah(
        content: '﴿فَاذْكُرُونِي أَذْكُرْكُمْ﴾',
        source: 'البقرة: 152',
      );
    }
    final daySeed = DateTime.now()
        .toUtc()
        .difference(DateTime(2024, 1, 1))
        .inDays;
    final index = daySeed % ayat.length;
    return ayat[index];
  }
}

class _DailyAyahParseInput {
  const _DailyAyahParseInput({required this.raw, required this.themes});

  final String raw;
  final List<String> themes;
}

List<DailyAyah> _parseLocalAyat(_DailyAyahParseInput input) {
  final data = jsonDecode(input.raw) as List<dynamic>;
  final list = <DailyAyah>[];

  for (final surahRaw in data) {
    final surah = surahRaw as Map<String, dynamic>;
    final surahName =
        (surah['name'] as Map<String, dynamic>? ?? const {})['ar']
            ?.toString() ??
        '';
    final verses = (surah['verses'] as List<dynamic>? ?? const []);
    for (final verseRaw in verses) {
      final verse = verseRaw as Map<String, dynamic>;
      final text =
          (verse['text'] as Map<String, dynamic>? ?? const {})['ar']
              ?.toString() ??
          '';
      if (!input.themes.any(text.contains)) {
        continue;
      }

      final number = verse['number'] as int? ?? 0;
      list.add(DailyAyah(content: '﴿$text﴾', source: '$surahName: $number'));
    }
  }

  return list;
}
