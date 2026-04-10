# Supabase Seeding Guide

This guide seeds the static app content into Supabase:
- Quran surahs and verses
- Adhkar categories and items
- Daily content records

## 0) Create schema and policies

Before seeding, run the SQL file in Supabase SQL Editor:

```sql
-- copy/paste docs/supabase-schema.sql and run it once
```

## 1) Install dependencies

Run:

```powershell
flutter pub get
```

## 2) Set environment variables (PowerShell)

Use your Supabase project values:

```powershell
$env:SUPABASE_URL="https://YOUR_PROJECT_ID.supabase.co"
$env:SUPABASE_SERVICE_ROLE_KEY="YOUR_SERVICE_ROLE_KEY"
```

Do not use anon key for seeding.

## 3) Dry run (validate parsing only)

No Supabase credentials are required for dry run.

```powershell
dart run tool/seed_supabase.dart --dry-run
```

## 4) Run actual seed

For actual seed, make sure environment variables from step 2 are set first.

```powershell
dart run tool/seed_supabase.dart
```

## 5) Quick SQL checks in Supabase

```sql
select count(*) as surahs_count from public.quran_surahs;
select count(*) as verses_count from public.quran_verses;
select count(*) as adhkar_categories_count from public.adhkar_categories;
select count(*) as adhkar_items_count from public.adhkar_items;
select count(*) as daily_content_count from public.daily_content;
```

## Notes

- Script path: tool/seed_supabase.dart
- Data source files are read from assets/data.
- The script is idempotent (uses upsert), so it can be re-run safely.
