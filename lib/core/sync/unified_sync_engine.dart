import 'package:supabase_flutter/supabase_flutter.dart';

class UnifiedSyncEngine {
  const UnifiedSyncEngine();

  Future<void> syncByKeys({
    required SupabaseClient client,
    required String table,
    required String userId,
    required List<String> keyColumns,
    required List<Map<String, dynamic>> desiredRows,
    String userIdColumn = 'user_id',
    String? onConflict,
  }) async {
    if (keyColumns.isEmpty) {
      throw ArgumentError('keyColumns cannot be empty');
    }

    if (desiredRows.isEmpty) {
      await client.from(table).delete().eq(userIdColumn, userId);
      return;
    }

    final normalizedDesired = desiredRows
        .map((row) => Map<String, dynamic>.from(row)..[userIdColumn] = userId)
        .toList(growable: false);

    final existingRowsResponse = await client
        .from(table)
        .select(keyColumns.join(', '))
        .eq(userIdColumn, userId);

    final existingRows = List<Map<String, dynamic>>.from(
      existingRowsResponse as List,
    );

    final existingByKey = <String, Map<String, dynamic>>{};
    for (final row in existingRows) {
      existingByKey[_keyForRow(row, keyColumns)] = row;
    }

    final desiredByKey = <String, Map<String, dynamic>>{};
    for (final row in normalizedDesired) {
      desiredByKey[_keyForRow(row, keyColumns)] = row;
    }

    for (final entry in desiredByKey.entries) {
      final key = entry.key;
      final row = entry.value;
      if (onConflict != null && onConflict.isNotEmpty) {
        continue;
      }

      if (existingByKey.containsKey(key)) {
        dynamic updateQuery = client
            .from(table)
            .update(row)
            .eq(userIdColumn, userId);
        for (final column in keyColumns) {
          updateQuery = _applyKeyFilter(updateQuery, column, row[column]);
        }
        await updateQuery;
      } else {
        await client.from(table).insert(row);
      }
    }

    if (onConflict != null && onConflict.isNotEmpty) {
      await client
          .from(table)
          .upsert(normalizedDesired, onConflict: onConflict);
    }

    for (final entry in existingByKey.entries) {
      if (desiredByKey.containsKey(entry.key)) {
        continue;
      }

      final row = entry.value;
      dynamic deleteQuery = client
          .from(table)
          .delete()
          .eq(userIdColumn, userId);
      for (final column in keyColumns) {
        deleteQuery = _applyKeyFilter(deleteQuery, column, row[column]);
      }
      await deleteQuery;
    }
  }

  String _keyForRow(Map<String, dynamic> row, List<String> columns) {
    return columns
        .map((column) {
          final value = row[column];
          return '$column:${value?.toString() ?? '<null>'}';
        })
        .join('|');
  }

  dynamic _applyKeyFilter(dynamic query, String column, dynamic value) {
    if (value == null) {
      return query.isFilter(column, null);
    }
    return query.eq(column, value);
  }
}
