import 'package:supabase_flutter/supabase_flutter.dart';

import 'settings_remote_mapper.dart';
import 'settings_state.dart';

class SettingsRemoteSyncService {
  const SettingsRemoteSyncService(this._supabaseClient);

  final SupabaseClient? _supabaseClient;

  Future<SettingsState?> load(SettingsState fallback) async {
    final userId = _supabaseClient?.auth.currentUser?.id;
    if (_supabaseClient == null || userId == null) return null;

    final data = await _supabaseClient
        .from('user_settings')
        .select(
          'lang_code, prayer_offset, play_adhan, sticky_notification, adhan_sound, quran_read_as_text, fasting_reminders_enabled, white_days_reminder_enabled, monday_thursday_reminder_enabled',
        )
        .eq('user_id', userId)
        .maybeSingle();

    if (data == null) return null;
    return SettingsRemoteMapper.fromRemote(data, fallback);
  }

  Future<void> save(SettingsState state) async {
    final userId = _supabaseClient?.auth.currentUser?.id;
    if (_supabaseClient == null || userId == null) return;

    await _supabaseClient
        .from('user_settings')
        .upsert(
          SettingsRemoteMapper.toRemote(userId: userId, state: state),
          onConflict: 'user_id',
        );
  }
}
