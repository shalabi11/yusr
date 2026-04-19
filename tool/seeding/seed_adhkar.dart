import 'dart:convert';
import 'dart:io';

import 'package:supabase/supabase.dart';

import 'seed_utils.dart';

Future<void> seedAdhkar(SupabaseClient? client, {required bool dryRun}) async {
  final file = File('assets/data/adhkar.json');
  if (!file.existsSync()) {
    throw Exception('Missing file: assets/data/adhkar.json');
  }

  final List<dynamic> raw =
      jsonDecode(await file.readAsString(encoding: utf8)) as List<dynamic>;

  final categoryRows = <Map<String, dynamic>>[];
  for (int i = 0; i < raw.length; i++) {
    final Map<String, dynamic> category = raw[i] as Map<String, dynamic>;
    final int sourceId = (category['id'] as num?)?.toInt() ?? (i + 1);
    categoryRows.add({
      'slug': 'adhkar_$sourceId',
      'name_ar': (category['category'] ?? '').toString(),
      'name_en': null,
      'sort_order': i,
      'is_active': true,
    });
  }

  stdout.writeln('Adhkar categories prepared: ${categoryRows.length}');
  if (!dryRun) {
    await upsertInChunks(
      client: client!,
      table: 'adhkar_categories',
      rows: categoryRows,
      onConflict: 'slug',
    );
  }

  final slugs = categoryRows.map((e) => e['slug'] as String).toList();
  final List<dynamic> fetched = dryRun
      ? <dynamic>[]
      : (await client!
                .from('adhkar_categories')
                .select('id,slug')
                .inFilter('slug', slugs)
            as List<dynamic>);

  final Map<String, int> categoryIdBySlug = {
    for (final dynamic row in fetched)
      (row as Map<String, dynamic>)['slug'].toString(): (row['id'] as num)
          .toInt(),
  };

  final itemRows = <Map<String, dynamic>>[];
  for (int i = 0; i < raw.length; i++) {
    final Map<String, dynamic> category = raw[i] as Map<String, dynamic>;
    final int sourceId = (category['id'] as num?)?.toInt() ?? (i + 1);
    final slug = 'adhkar_$sourceId';
    final categoryId = categoryIdBySlug[slug];
    if (!dryRun && categoryId == null) {
      throw Exception('Could not find inserted category for slug=$slug');
    }

    final List<dynamic> items =
        (category['array'] as List<dynamic>?) ?? const [];
    for (int j = 0; j < items.length; j++) {
      final item = items[j] as Map<String, dynamic>;
      itemRows.add({
        'category_id': categoryId ?? -1,
        'text_ar': (item['text'] ?? '').toString(),
        'repeat_count': (item['count'] as num?)?.toInt() ?? 1,
        'sort_order': j,
      });
    }
  }

  stdout.writeln('Adhkar items prepared: ${itemRows.length}');
  if (dryRun) return;

  await upsertInChunks(
    client: client!,
    table: 'adhkar_items',
    rows: itemRows,
    onConflict: 'category_id,sort_order',
  );

  stdout.writeln('Adhkar seeded successfully.');
}
