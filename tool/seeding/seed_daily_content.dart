import 'dart:convert';
import 'dart:io';

import 'package:supabase/supabase.dart';

import 'seed_utils.dart';

Future<void> seedDailyContent(
  SupabaseClient? client, {
  required bool dryRun,
}) async {
  final file = File('assets/data/daily_content.json');
  if (!file.existsSync()) {
    stdout.writeln('Skipping daily content: file not found.');
    return;
  }

  final List<dynamic> raw =
      jsonDecode(await file.readAsString(encoding: utf8)) as List<dynamic>;

  final baseDate = DateTime.utc(2024, 1, 1);
  final rows = <Map<String, dynamic>>[];

  for (int i = 0; i < raw.length; i++) {
    final row = raw[i] as Map<String, dynamic>;
    final date = baseDate.add(Duration(days: i));

    rows.add({
      'content_date': date.toIso8601String().split('T').first,
      'content': (row['content'] ?? '').toString(),
      'source': (row['source'] ?? '').toString(),
      'theme': (row['type'] ?? '').toString(),
    });
  }

  stdout.writeln('Daily content prepared: ${rows.length}');
  if (dryRun) return;

  await upsertInChunks(
    client: client!,
    table: 'daily_content',
    rows: rows,
    onConflict: 'content_date',
  );

  stdout.writeln('Daily content seeded successfully.');
}
