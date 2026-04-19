-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.adhkar_categories (
  id bigint NOT NULL DEFAULT nextval('adhkar_categories_id_seq'::regclass),
  slug text NOT NULL UNIQUE,
  name_ar text NOT NULL,
  name_en text,
  sort_order integer NOT NULL DEFAULT 0,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT adhkar_categories_pkey PRIMARY KEY (id)
);
CREATE TABLE public.adhkar_items (
  id bigint NOT NULL DEFAULT nextval('adhkar_items_id_seq'::regclass),
  category_id bigint NOT NULL,
  text_ar text NOT NULL,
  repeat_count integer NOT NULL DEFAULT 1 CHECK (repeat_count > 0),
  sort_order integer NOT NULL DEFAULT 0,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT adhkar_items_pkey PRIMARY KEY (id),
  CONSTRAINT adhkar_items_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.adhkar_categories(id)
);
CREATE TABLE public.assistant_conversations (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  status text NOT NULL DEFAULT 'active'::text CHECK (status = ANY (ARRAY['active'::text, 'archived'::text])),
  title text,
  meta jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT assistant_conversations_pkey PRIMARY KEY (id),
  CONSTRAINT assistant_conversations_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.assistant_messages (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  conversation_id uuid NOT NULL,
  user_id uuid NOT NULL,
  role text NOT NULL CHECK (role = ANY (ARRAY['user'::text, 'assistant'::text, 'system'::text])),
  type text,
  message text NOT NULL,
  sources jsonb NOT NULL DEFAULT '[]'::jsonb,
  action_name text,
  action_args jsonb,
  confirmation_required boolean NOT NULL DEFAULT false,
  success boolean,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT assistant_messages_pkey PRIMARY KEY (id),
  CONSTRAINT assistant_messages_conversation_id_fkey FOREIGN KEY (conversation_id) REFERENCES public.assistant_conversations(id),
  CONSTRAINT assistant_messages_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.automation_outbox (
  id bigint NOT NULL DEFAULT nextval('automation_outbox_id_seq'::regclass),
  user_id uuid,
  event_type text NOT NULL,
  payload jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  processed_at timestamp with time zone,
  CONSTRAINT automation_outbox_pkey PRIMARY KEY (id),
  CONSTRAINT automation_outbox_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.daily_content (
  id bigint NOT NULL DEFAULT nextval('daily_content_id_seq'::regclass),
  content_date date NOT NULL UNIQUE,
  content text NOT NULL,
  source text NOT NULL,
  theme text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT daily_content_pkey PRIMARY KEY (content_date)
);
CREATE TABLE public.prayer_time_snapshots (
  id bigint NOT NULL DEFAULT nextval('prayer_time_snapshots_id_seq'::regclass),
  user_id uuid NOT NULL,
  source text NOT NULL DEFAULT 'aladhan'::text,
  method smallint NOT NULL DEFAULT 4,
  location_name text,
  prayer_date date NOT NULL DEFAULT ((now() AT TIME ZONE 'utc'::text))::date,
  fajr time without time zone NOT NULL,
  sunrise time without time zone NOT NULL,
  dhuhr time without time zone NOT NULL,
  asr time without time zone NOT NULL,
  maghrib time without time zone NOT NULL,
  isha time without time zone NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT prayer_time_snapshots_pkey PRIMARY KEY (id),
  CONSTRAINT prayer_time_snapshots_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.profiles_backup (
  id uuid,
  display_name text,
  avatar_url text,
  created_at timestamp with time zone,
  updated_at timestamp with time zone
);
CREATE TABLE public.quran_surahs (
  surah_number integer NOT NULL CHECK (surah_number >= 1 AND surah_number <= 114),
  name_ar text NOT NULL,
  name_en text NOT NULL,
  verses_count integer NOT NULL CHECK (verses_count > 0),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT quran_surahs_pkey PRIMARY KEY (surah_number)
);
CREATE TABLE public.quran_verses (
  id bigint NOT NULL DEFAULT nextval('quran_verses_id_seq'::regclass),
  surah_number integer NOT NULL,
  verse_number integer NOT NULL CHECK (verse_number > 0),
  text_ar text NOT NULL,
  juz_number integer NOT NULL CHECK (juz_number >= 1 AND juz_number <= 30),
  page_number integer NOT NULL CHECK (page_number >= 1 AND page_number <= 604),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT quran_verses_pkey PRIMARY KEY (surah_number, verse_number),
  CONSTRAINT quran_verses_surah_number_fkey FOREIGN KEY (surah_number) REFERENCES public.quran_surahs(surah_number)
);
CREATE TABLE public.reminders (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  title text NOT NULL,
  type text NOT NULL,
  hour integer NOT NULL CHECK (hour >= 0 AND hour <= 23),
  minute integer NOT NULL CHECK (minute >= 0 AND minute <= 59),
  repeat text NOT NULL,
  enabled boolean NOT NULL DEFAULT true,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT reminders_pkey PRIMARY KEY (id),
  CONSTRAINT reminders_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.user_khatma_plans (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  days smallint NOT NULL CHECK (days > 0),
  pages_per_day smallint NOT NULL CHECK (pages_per_day > 0),
  juz_per_day numeric NOT NULL CHECK (juz_per_day > 0::numeric),
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT user_khatma_plans_pkey PRIMARY KEY (id),
  CONSTRAINT user_khatma_plans_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.user_locations (
  user_id uuid NOT NULL,
  manual_location_enabled boolean NOT NULL DEFAULT false,
  manual_lat double precision CHECK (manual_lat IS NULL OR manual_lat >= '-90'::integer::double precision AND manual_lat <= 90::double precision),
  manual_lng double precision CHECK (manual_lng IS NULL OR manual_lng >= '-180'::integer::double precision AND manual_lng <= 180::double precision),
  manual_city text,
  timezone text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT user_locations_pkey PRIMARY KEY (user_id),
  CONSTRAINT user_locations_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.user_profiles (
  user_id uuid NOT NULL,
  username text NOT NULL CHECK (char_length(username) >= 3 AND char_length(username) <= 30),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  avatar_url text,
  CONSTRAINT user_profiles_pkey PRIMARY KEY (user_id),
  CONSTRAINT user_profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.user_quran_bookmarks (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  surah_number integer NOT NULL,
  verse_number integer NOT NULL CHECK (verse_number > 0),
  page_number integer NOT NULL CHECK (page_number >= 1 AND page_number <= 604),
  juz_number integer NOT NULL CHECK (juz_number >= 1 AND juz_number <= 30),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT user_quran_bookmarks_pkey PRIMARY KEY (id),
  CONSTRAINT user_quran_bookmarks_surah_number_fkey FOREIGN KEY (surah_number) REFERENCES public.quran_surahs(surah_number),
  CONSTRAINT user_quran_bookmarks_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.user_quran_last_read (
  user_id uuid NOT NULL,
  surah_number integer NOT NULL,
  verse_number integer NOT NULL CHECK (verse_number > 0),
  page_number integer NOT NULL CHECK (page_number >= 1 AND page_number <= 604),
  juz_number integer NOT NULL CHECK (juz_number >= 1 AND juz_number <= 30),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT user_quran_last_read_pkey PRIMARY KEY (user_id),
  CONSTRAINT user_quran_last_read_surah_number_fkey FOREIGN KEY (surah_number) REFERENCES public.quran_surahs(surah_number),
  CONSTRAINT user_quran_last_read_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.user_reminders (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  user_id uuid NOT NULL,
  title text NOT NULL,
  subtitle text NOT NULL,
  frequency text NOT NULL CHECK (frequency = ANY (ARRAY['daily'::text, 'weekly_friday'::text])),
  weekday integer,
  time_of_day time without time zone NOT NULL,
  enabled boolean NOT NULL DEFAULT true,
  icon_code_point integer NOT NULL DEFAULT 0,
  source_id text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT user_reminders_pkey PRIMARY KEY (id),
  CONSTRAINT user_reminders_user_id_fkey1 FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.user_reminders_legacy (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  title text NOT NULL,
  subtitle text,
  frequency USER-DEFINED NOT NULL DEFAULT 'daily'::reminder_frequency,
  weekday smallint CHECK (weekday IS NULL OR weekday >= 1 AND weekday <= 7),
  time_of_day time without time zone NOT NULL,
  enabled boolean NOT NULL DEFAULT true,
  icon_code_point integer,
  source USER-DEFINED NOT NULL DEFAULT 'custom'::reminder_source,
  source_id text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT user_reminders_legacy_pkey PRIMARY KEY (id),
  CONSTRAINT user_reminders_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.user_settings (
  user_id uuid NOT NULL,
  lang_code text NOT NULL DEFAULT 'ar'::text CHECK (lang_code = ANY (ARRAY['ar'::text, 'en'::text])),
  prayer_offset smallint NOT NULL DEFAULT 0 CHECK (prayer_offset = ANY (ARRAY[0, 5, 10, 15])),
  play_adhan boolean NOT NULL DEFAULT true,
  sticky_notification boolean NOT NULL DEFAULT false,
  adhan_sound text NOT NULL DEFAULT 'adhan'::text CHECK (adhan_sound = ANY (ARRAY['adhan'::text, 'adhan_makkah'::text, 'adhan_madina'::text])),
  quran_read_as_text boolean NOT NULL DEFAULT true,
  fasting_reminders_enabled boolean NOT NULL DEFAULT false,
  white_days_reminder_enabled boolean NOT NULL DEFAULT false,
  monday_thursday_reminder_enabled boolean NOT NULL DEFAULT false,
  intro_seen boolean NOT NULL DEFAULT false,
  reminders_swipe_hint_seen boolean NOT NULL DEFAULT false,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT user_settings_pkey PRIMARY KEY (user_id),
  CONSTRAINT user_settings_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);