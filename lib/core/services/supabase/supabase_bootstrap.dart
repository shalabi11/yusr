import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseBootstrap {
  static const String _url = String.fromEnvironment('SUPABASE_URL');
  static const String _anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool _initialized = false;
  static bool _enabled = false;

  static bool get isEnabled => _enabled;

  static SupabaseClient? get client =>
      _enabled ? Supabase.instance.client : null;

  static String? get currentUserId =>
      _enabled ? Supabase.instance.client.auth.currentUser?.id : null;

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    if (_url.isEmpty || _anonKey.isEmpty) {
      debugPrint(
        '[Supabase] Disabled: missing SUPABASE_URL or SUPABASE_ANON_KEY dart-define values.',
      );
      return;
    }

    await Supabase.initialize(url: _url, anonKey: _anonKey);
    _enabled = true;

    final auth = Supabase.instance.client.auth;
    if (auth.currentSession == null) {
      try {
        await auth.signInAnonymously();
      } catch (e) {
        debugPrint('[Supabase] Anonymous sign-in failed: $e');
      }
    }
  }
}
