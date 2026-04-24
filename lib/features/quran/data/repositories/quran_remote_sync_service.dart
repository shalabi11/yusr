import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/quran_models.dart';

class QuranRemoteSyncService {
  QuranRemoteSyncService(this._supabaseClient);

  final SupabaseClient? _supabaseClient;

  Future<QuranLastRead?> loadLastRead() async {
    final userId = _supabaseClient?.auth.currentUser?.id;
    if (_supabaseClient == null || userId == null) return null;

    final data = await _supabaseClient
        .from('user_quran_last_read')
        .select('surah_number, verse_number, page_number, juz_number')
        .eq('user_id', userId)
        .maybeSingle();

    if (data == null) return null;

    return QuranLastRead(
      surahNumber: (data['surah_number'] as int?) ?? 1,
      verseNumber: (data['verse_number'] as int?) ?? 1,
      pageNumber: (data['page_number'] as int?) ?? 1,
      juzNumber: (data['juz_number'] as int?) ?? 1,
    );
  }

  Future<void> saveLastRead(QuranLastRead lastRead) async {
    final userId = _supabaseClient?.auth.currentUser?.id;
    if (_supabaseClient == null || userId == null) return;

    await _supabaseClient.from('user_quran_last_read').upsert({
      'user_id': userId,
      'surah_number': lastRead.surahNumber,
      'verse_number': lastRead.verseNumber,
      'page_number': lastRead.pageNumber,
      'juz_number': lastRead.juzNumber,
    }, onConflict: 'user_id');
  }

  Future<List<QuranBookmark>> loadBookmarks() async {
    final userId = _supabaseClient?.auth.currentUser?.id;
    if (_supabaseClient == null || userId == null) return const [];

    final rows = await _supabaseClient
        .from('user_quran_bookmarks')
        .select(
          'id, surah_number, verse_number, page_number, juz_number, created_at',
        )
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (rows as List<dynamic>).map((dynamic row) {
      final map = row as Map<String, dynamic>;
      return QuranBookmark(
        id: map['id']?.toString() ?? '',
        surahNumber: (map['surah_number'] as int?) ?? 1,
        verseNumber: (map['verse_number'] as int?) ?? 1,
        pageNumber: (map['page_number'] as int?) ?? 1,
        juzNumber: (map['juz_number'] as int?) ?? 1,
        createdAt:
            DateTime.tryParse(map['created_at']?.toString() ?? '') ??
            DateTime.now(),
      );
    }).toList();
  }

  Future<void> saveBookmarks(List<QuranBookmark> bookmarks) async {
    final client = _supabaseClient;
    final userId = client?.auth.currentUser?.id;
    if (client == null || userId == null) return;

    await client.from('user_quran_bookmarks').delete().eq('user_id', userId);

    if (bookmarks.isEmpty) {
      return;
    }

    final rows = bookmarks
        .map(
          (bookmark) => {
            'user_id': userId,
            'surah_number': bookmark.surahNumber,
            'verse_number': bookmark.verseNumber,
            'page_number': bookmark.pageNumber,
            'juz_number': bookmark.juzNumber,
            'created_at': bookmark.createdAt.toIso8601String(),
          },
        )
        .toList(growable: false);

    await client.from('user_quran_bookmarks').insert(rows);
  }
}
