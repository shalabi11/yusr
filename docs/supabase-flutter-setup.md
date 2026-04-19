# Supabase Flutter Setup

This app now supports optional Supabase runtime bootstrap.

## How it works

- File: lib/core/services/supabase/supabase_bootstrap.dart
- It reads values from compile-time defines:
  - SUPABASE_URL
  - SUPABASE_ANON_KEY
- If missing, app continues in local mode (no crash).
- If provided, it initializes Supabase and signs in anonymously.

## Run command (PowerShell)

```powershell
flutter run --dart-define=SUPABASE_URL=https://YOUR_PROJECT_ID.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

## Notes

- Use ANON key in app runtime.
- Do not ship service role key in Flutter app.
- Service role key is only for backend/admin tasks (like seeding, n8n, secure servers).
