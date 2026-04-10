import 'dart:io';

import 'package:supabase/supabase.dart';

const int chunkSize = 250;
const int maxChunkAttempts = 4;

Future<void> upsertInChunks({
  required SupabaseClient client,
  required String table,
  required List<Map<String, dynamic>> rows,
  required String onConflict,
}) async {
  if (rows.isEmpty) {
    stdout.writeln('No rows to upsert for $table.');
    return;
  }

  for (int i = 0; i < rows.length; i += chunkSize) {
    final end = (i + chunkSize < rows.length) ? i + chunkSize : rows.length;
    final batch = rows.sublist(i, end);

    var attempt = 1;
    while (true) {
      try {
        await client.from(table).upsert(batch, onConflict: onConflict);
        stdout.writeln('Upserted $table rows ${i + 1}..$end/${rows.length}');
        break;
      } catch (e) {
        if (attempt >= maxChunkAttempts) rethrow;
        stdout.writeln(
          'Retrying $table rows ${i + 1}..$end (attempt $attempt failed: $e)',
        );
        await Future<void>.delayed(Duration(seconds: attempt));
        attempt++;
      }
    }
  }
}
