import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseBootstrap {
  static const String _url = String.fromEnvironment('SUPABASE_URL');
  static const String _anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  // Fallback values keep debug/dev runs working even when --dart-define is skipped.
  static const String _fallbackUrl = 'https://rkpjvaibupjagdpsfnnz.supabase.co';
  static const String _fallbackAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJrcGp2YWlidXBqYWdkcHNmbm56Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU3MDE2NjIsImV4cCI6MjA5MTI3NzY2Mn0.k97Zfmw7QsGkrGzKQje987PJwSmQqrpjdl2LPJtD3eI';

  static bool _initialized = false;
  static bool _enabled = false;

  static bool get isEnabled => _enabled;

  static SupabaseClient? get client =>
      _enabled ? Supabase.instance.client : null;

  static String? get currentUserId =>
      _enabled ? Supabase.instance.client.auth.currentUser?.id : null;

  static Future<void> init() async {
    if (_initialized) return;

    final resolvedUrl = _url.isNotEmpty ? _url : _fallbackUrl;
    final resolvedAnonKey = _anonKey.isNotEmpty ? _anonKey : _fallbackAnonKey;

    if (resolvedUrl.isEmpty || resolvedAnonKey.isEmpty) {
      debugPrint('[Supabase] Disabled: missing Supabase credentials.');
      return;
    }

    try {
      await Supabase.initialize(url: resolvedUrl, anonKey: resolvedAnonKey);
      _enabled = true;
      _initialized = true;
    } catch (e) {
      _enabled = false;
      debugPrint('[Supabase] Initialization failed: $e');
      return;
    }

    await ensureAnonymousSession();
  }

  static Future<void> ensureAnonymousSession() async {
    if (!_enabled) return;

    final auth = Supabase.instance.client.auth;
    if (auth.currentSession != null) return;

    try {
      await auth.signInAnonymously();
    } catch (e) {
      debugPrint('[Supabase] Anonymous sign-in failed: $e');
    }
  }
}
