import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yusr_app/core/localization/app_translations.dart';

import '../models/reminder_model.dart';
import 'reminders_remote_sync_utils.dart';

class RemindersRemoteSyncService {
  const RemindersRemoteSyncService(this._supabaseClient);

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
    final userId = _supabaseClient?.auth.currentUser?.id;
    if (_supabaseClient == null || userId == null) return;

    await _supabaseClient.from('user_reminders').delete().eq('user_id', userId);

    if (reminders.isEmpty) return;

    final rows = reminders.map((r) {
      final isWeeklyFriday = r.subtitleKey == AppStrings.weeklyFriday;
      return <String, dynamic>{
        'user_id': userId,
        'title': r.titleKey,
        'subtitle': r.subtitleKey,
        'frequency': isWeeklyFriday ? 'weekly_friday' : 'daily',
        'weekday': isWeeklyFriday ? DateTime.friday : null,
        'time_of_day': toReminderSqlTime(r.hour, r.minute),
        'enabled': r.enabled,
        'icon_code_point': r.iconCodeInfo,
        'source_id': r.id,
      };
    }).toList();

    await _supabaseClient.from('user_reminders').insert(rows);
  }
}
