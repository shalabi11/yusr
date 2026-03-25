import 'dart:convert';

import 'package:flutter/services.dart';

class DailyAyah {
  final String content;
  final String source;

  const DailyAyah({required this.content, required this.source});
}

class DailyAyahRepository {
  static List<DailyAyah>? _cache;

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

    final raw = await rootBundle.loadString('assets/data/mainDataQuran.json');
    final List<dynamic> data = jsonDecode(raw) as List<dynamic>;

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
        final hasTheme = _themes.any(text.contains);
        if (!hasTheme) continue;
        final number = verse['number'] as int? ?? 0;
        list.add(DailyAyah(content: '﴿$text﴾', source: '$surahName: $number'));
      }
    }

    _cache = list;
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
