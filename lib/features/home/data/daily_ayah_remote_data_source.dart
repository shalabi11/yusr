import 'package:supabase_flutter/supabase_flutter.dart';

import 'daily_ayah_model.dart';

class DailyAyahRemoteDataSource {
  const DailyAyahRemoteDataSource(this._supabaseClient);

  final SupabaseClient? _supabaseClient;

  Future<List<DailyAyah>?> loadDailyAyat() async {
    final client = _supabaseClient;
    if (client == null) return null;

    final rows = await client
        .from('daily_content')
        .select('content_date, content, source')
        .order('content_date', ascending: true);

    final data = (rows as List<dynamic>).cast<Map<String, dynamic>>();
    if (data.isEmpty) return const <DailyAyah>[];

    return data
        .map(
          (row) => DailyAyah(
            content: row['content']?.toString() ?? '',
            source: row['source']?.toString() ?? '',
          ),
        )
        .where((ayah) => ayah.content.isNotEmpty)
        .toList();
  }
}
