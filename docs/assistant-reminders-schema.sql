-- Assistant reminders table (MVP)
create extension if not exists "pgcrypto";

create table if not exists public.reminders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  type text not null,
  hour int not null check (hour between 0 and 23),
  minute int not null check (minute between 0 and 59),
  repeat text not null,
  enabled boolean not null default true,
  created_at timestamptz not null default now()
);

create index if not exists idx_reminders_user_id on public.reminders (user_id);
create index if not exists idx_reminders_user_id_enabled on public.reminders (user_id, enabled);

alter table public.reminders enable row level security;

drop policy if exists reminders_owner_all on public.reminders;
create policy reminders_owner_all
on public.reminders
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);
