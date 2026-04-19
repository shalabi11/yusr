import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/quran_models.dart';

class QuranCatalogRemoteService {
  const QuranCatalogRemoteService(this._supabaseClient);

  final SupabaseClient? _supabaseClient;

  Future<Map<int, String>> loadPageImageUrls() async {
    final client = _supabaseClient;
    if (client == null) return const <int, String>{};

    final rows = await client
        .from('quran_page_images')
        .select('page_number, url')
        .eq('is_active', true)
        .order('page_number', ascending: true);

    final data = (rows as List<dynamic>).cast<Map<String, dynamic>>();
    if (data.isEmpty) return const <int, String>{};

    final result = <int, String>{};
    for (final row in data) {
      final pageNumber = (row['page_number'] as num?)?.toInt();
      final url = row['url']?.toString() ?? '';
      if (pageNumber == null || pageNumber <= 0 || url.isEmpty) {
        continue;
      }
      result[pageNumber] = url;
    }
    return result;
  }

  Future<List<QuranSurah>?> loadSurahs() async {
    final client = _supabaseClient;
    if (client == null) return null;

    final surahRows = await client
        .from('quran_surahs')
        .select('surah_number, name_ar, name_en, verses_count')
        .order('surah_number', ascending: true);

    final surahData = (surahRows as List<dynamic>).cast<Map<String, dynamic>>();
    if (surahData.isEmpty) return const <QuranSurah>[];

    final verses = await _loadAllVerses(client);
    final versesBySurah = <int, List<QuranVerse>>{};
    for (final verse in verses) {
      final surahNumber = (verse['surah_number'] as num?)?.toInt();
      if (surahNumber == null) continue;
      final list = versesBySurah.putIfAbsent(surahNumber, () => <QuranVerse>[]);
      list.add(
        QuranVerse(
          number: (verse['verse_number'] as num?)?.toInt() ?? 0,
          textAr: verse['text_ar']?.toString() ?? '',
          juz: (verse['juz_number'] as num?)?.toInt() ?? 1,
          page: (verse['page_number'] as num?)?.toInt() ?? 1,
        ),
      );
    }

    final surahs = <QuranSurah>[];
    for (final row in surahData) {
      final number = (row['surah_number'] as num?)?.toInt() ?? 0;
      surahs.add(
        QuranSurah(
          number: number,
          nameAr: row['name_ar']?.toString() ?? '',
          nameEn: row['name_en']?.toString() ?? '',
          versesCount: (row['verses_count'] as num?)?.toInt() ?? 0,
          verses: versesBySurah[number] ?? const <QuranVerse>[],
        ),
      );
    }

    return surahs;
  }

  Future<List<Map<String, dynamic>>> _loadAllVerses(
    SupabaseClient client,
  ) async {
    const pageSize = 1000;
    var from = 0;
    final allRows = <Map<String, dynamic>>[];

    while (true) {
      final to = from + pageSize - 1;
      final rows = await client
          .from('quran_verses')
          .select(
            'surah_number, verse_number, text_ar, juz_number, page_number',
          )
          .order('surah_number', ascending: true)
          .order('verse_number', ascending: true)
          .range(from, to);

      final chunk = (rows as List<dynamic>).cast<Map<String, dynamic>>();
      if (chunk.isEmpty) break;

      allRows.addAll(chunk);
      if (chunk.length < pageSize) break;
      from += pageSize;
    }

    return allRows;
  }
}
