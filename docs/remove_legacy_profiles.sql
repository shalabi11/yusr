-- Remove legacy public.profiles safely
-- Run with service role in Supabase SQL Editor.

begin;

-- 1) Backup legacy table once (optional but recommended)
do $$
begin
  if to_regclass('public.profiles') is not null
     and to_regclass('public.profiles_backup') is null then
    execute 'create table public.profiles_backup as table public.profiles';
  end if;
end $$;

-- 2) Ensure user_profiles contains any missing rows from legacy profiles
do $$
begin
  if to_regclass('public.profiles') is not null then
    insert into public.user_profiles (user_id, username, avatar_url, created_at, updated_at)
    select
      p.id,
      case
        when char_length(trim(coalesce(p.display_name, ''))) between 3 and 30
          then trim(p.display_name)
        else left('user_' || substr(replace(p.id::text, '-', ''), 1, 24), 30)
      end as username,
      p.avatar_url,
      p.created_at,
      p.updated_at
    from public.profiles p
    where not exists (
      select 1 from public.user_profiles up where up.user_id = p.id
    );

    update public.user_profiles up
    set avatar_url = p.avatar_url,
        updated_at = now()
    from public.profiles p
    where up.user_id = p.id
      and up.avatar_url is null
      and p.avatar_url is not null;
  end if;
end $$;

-- 3) Re-point foreign keys that still reference public.profiles(id)
alter table if exists public.automation_outbox
  drop constraint if exists automation_outbox_user_id_fkey;
alter table if exists public.automation_outbox
  add constraint automation_outbox_user_id_fkey
  foreign key (user_id) references auth.users(id) on delete set null;

alter table if exists public.prayer_time_snapshots
  drop constraint if exists prayer_time_snapshots_user_id_fkey;
alter table if exists public.prayer_time_snapshots
  add constraint prayer_time_snapshots_user_id_fkey
  foreign key (user_id) references auth.users(id) on delete cascade;

alter table if exists public.user_khatma_plans
  drop constraint if exists user_khatma_plans_user_id_fkey;
alter table if exists public.user_khatma_plans
  add constraint user_khatma_plans_user_id_fkey
  foreign key (user_id) references auth.users(id) on delete cascade;

alter table if exists public.user_locations
  drop constraint if exists user_locations_user_id_fkey;
alter table if exists public.user_locations
  add constraint user_locations_user_id_fkey
  foreign key (user_id) references auth.users(id) on delete cascade;

alter table if exists public.user_reminders_legacy
  drop constraint if exists user_reminders_user_id_fkey;
alter table if exists public.user_reminders_legacy
  add constraint user_reminders_user_id_fkey
  foreign key (user_id) references auth.users(id) on delete cascade;

-- 4) Safety check: block drop if anything still depends on public.profiles
do $$
declare
  deps int;
begin
  if to_regclass('public.profiles') is null then
    return;
  end if;

  select count(*) into deps
  from pg_constraint c
  where c.contype = 'f'
    and c.confrelid = 'public.profiles'::regclass;

  if deps > 0 then
    raise exception 'Cannot drop public.profiles: still has % foreign key dependencies', deps;
  end if;
end $$;

-- 5) Drop legacy table
drop table if exists public.profiles;

commit;
