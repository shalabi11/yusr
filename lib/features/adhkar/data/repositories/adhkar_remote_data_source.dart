import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/adhkar_models.dart';

class AdhkarRemoteDataSource {
  const AdhkarRemoteDataSource(this._supabaseClient);

  final SupabaseClient? _supabaseClient;

  Future<List<AdhkarCategory>?> loadCategories() async {
    final client = _supabaseClient;
    if (client == null) return null;

    final categoriesRows = await client
        .from('adhkar_categories')
        .select('id, name_ar, sort_order')
        .eq('is_active', true)
        .order('sort_order', ascending: true);

    final categoriesData = (categoriesRows as List<dynamic>)
        .cast<Map<String, dynamic>>();
    if (categoriesData.isEmpty) return const <AdhkarCategory>[];

    final categoryIds = categoriesData
        .map((row) => (row['id'] as num?)?.toInt())
        .whereType<int>()
        .toList();

    if (categoryIds.isEmpty) return const <AdhkarCategory>[];

    final itemsRows = await client
        .from('adhkar_items')
        .select('id, category_id, text_ar, repeat_count, sort_order')
        .inFilter('category_id', categoryIds)
        .order('sort_order', ascending: true);

    final itemsData = (itemsRows as List<dynamic>).cast<Map<String, dynamic>>();

    final itemsByCategory = <int, List<AdhkarItem>>{};
    for (final row in itemsData) {
      final categoryId = (row['category_id'] as num?)?.toInt();
      if (categoryId == null) continue;
      final list = itemsByCategory.putIfAbsent(
        categoryId,
        () => <AdhkarItem>[],
      );
      list.add(
        AdhkarItem(
          id: (row['id'] as num?)?.toInt() ?? 0,
          text: row['text_ar']?.toString() ?? '',
          count: (row['repeat_count'] as num?)?.toInt() ?? 1,
        ),
      );
    }

    final categories = <AdhkarCategory>[];
    for (final row in categoriesData) {
      final id = (row['id'] as num?)?.toInt() ?? 0;
      categories.add(
        AdhkarCategory(
          id: id,
          category: row['name_ar']?.toString() ?? '',
          items: itemsByCategory[id] ?? const <AdhkarItem>[],
        ),
      );
    }
    return categories;
  }
}
