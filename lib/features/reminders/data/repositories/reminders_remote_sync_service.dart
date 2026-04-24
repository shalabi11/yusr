import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yusr_app/core/localization/app_translations.dart';

import '../models/reminder_model.dart';
import 'reminders_remote_sync_utils.dart';

class RemindersRemoteSyncService {
  RemindersRemoteSyncService(this._supabaseClient);

  final SupabaseClient? _supabaseClient;

  Future<List<ReminderModel>?> load() async {
    final userId = _supabaseClient?.auth.currentUser?.id;
    if (_supabaseClient == null || userId == null) return null;

    final List<dynamic> rows = await _supabaseClient
        .from('user_reminders')
        .select(
          'title, subtitle, frequency, time_of_day, enabled, icon_code_point, source_id',
        )
        .eq('user_id', userId)
        .order('time_of_day', ascending: true);

    if (rows.isEmpty) return <ReminderModel>[];

    final reminders = <ReminderModel>[];
    final usedIds = <int>{};

    for (final dynamic row in rows) {
      final map = row as Map<String, dynamic>;
      reminders.add(mapReminderFromRemote(map, usedIds));
    }

    return reminders;
  }

  Future<void> save(List<ReminderModel> reminders) async {
    final client = _supabaseClient;
    final userId = client?.auth.currentUser?.id;
    if (client == null || userId == null) {
      return;
    }

    await client.from('user_reminders').delete().eq('user_id', userId);

    if (reminders.isEmpty) {
      return;
    }

    final rows = reminders
        .map((reminder) {
          final isWeeklyFriday =
              reminder.subtitleKey == AppStrings.weeklyFriday;
          final sourceId = reminder.id.trim().isEmpty
              ? '${reminder.titleKey}-${reminder.hour}-${reminder.minute}'
              : reminder.id;

          return <String, dynamic>{
            'user_id': userId,
            'title': reminder.titleKey,
            'subtitle': reminder.subtitleKey,
            'frequency': isWeeklyFriday ? 'weekly_friday' : 'daily',
            'weekday': isWeeklyFriday ? DateTime.friday : null,
            'time_of_day': toReminderSqlTime(reminder.hour, reminder.minute),
            'enabled': reminder.enabled,
            'icon_code_point': reminder.iconCodeInfo,
            'source_id': sourceId,
          };
        })
        .toList(growable: false);

    await client.from('user_reminders').insert(rows);
  }
}
