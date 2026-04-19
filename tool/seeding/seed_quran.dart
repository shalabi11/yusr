import 'dart:convert';
import 'dart:io';

import 'package:supabase/supabase.dart';

import 'seed_utils.dart';

Future<void> seedQuran(SupabaseClient? client, {required bool dryRun}) async {
  final file = File('assets/data/mainDataQuran.json');
  if (!file.existsSync()) {
    throw Exception('Missing file: assets/data/mainDataQuran.json');
  }

  final List<dynamic> raw =
      jsonDecode(await file.readAsString(encoding: utf8)) as List<dynamic>;

  final surahRows = <Map<String, dynamic>>[];
  final verseRows = <Map<String, dynamic>>[];

  for (final dynamic surahRaw in raw) {
    final surah = surahRaw as Map<String, dynamic>;
    final int surahNumber = (surah['number'] as num?)?.toInt() ?? 0;
    final Map<String, dynamic> name =
        (surah['name'] as Map<String, dynamic>?) ?? const {};
    final List<dynamic> verses =
        (surah['verses'] as List<dynamic>?) ?? const [];

    surahRows.add({
      'surah_number': surahNumber,
      'name_ar': (name['ar'] ?? '').toString(),
      'name_en': (name['en'] ?? '').toString(),
      'verses_count': (surah['verses_count'] as num?)?.toInt() ?? verses.length,
    });

    for (final dynamic verseRaw in verses) {
      final verse = verseRaw as Map<String, dynamic>;
      final text = (verse['text'] as Map<String, dynamic>?) ?? const {};

      verseRows.add({
        'surah_number': surahNumber,
        'verse_number': (verse['number'] as num?)?.toInt() ?? 0,
        'text_ar': (text['ar'] ?? '').toString(),
        'juz_number': (verse['juz'] as num?)?.toInt() ?? 1,
        'page_number': (verse['page'] as num?)?.toInt() ?? 1,
      });
    }
  }

  stdout.writeln(
    'Quran payload prepared: surahs=${surahRows.length}, verses=${verseRows.length}',
  );
  if (dryRun) return;

  await upsertInChunks(
    client: client!,
    table: 'quran_surahs',
    rows: surahRows,
    onConflict: 'surah_number',
  );

  await upsertInChunks(
    client: client,
    table: 'quran_verses',
    rows: verseRows,
    onConflict: 'surah_number,verse_number',
  );

  stdout.writeln('Quran seeded successfully.');
}
