-- BrainBox initial schema. Run with `supabase db push` after linking a project.
-- Every mutable table is protected by row-level security.

create extension if not exists "pgcrypto";

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null check (char_length(display_name) between 1 and 60),
  bio text not null default '',
  avatar_url text,
  xp integer not null default 0 check (xp >= 0),
  total_xp integer not null default 0 check (total_xp >= 0),
  current_streak integer not null default 0 check (current_streak >= 0),
  longest_streak integer not null default 0 check (longest_streak >= 0),
  last_lesson_completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.courses (
  id text primary key,
  title text not null,
  short_description text not null,
  long_description text not null,
  category text not null,
  difficulty text not null,
  thumbnail_url text not null default '',
  estimated_hours integer not null default 0,
  lesson_count integer not null default 0,
  quiz_count integer not null default 0,
  project_count integer not null default 0,
  prerequisites jsonb not null default '[]'::jsonb,
  learning_outcomes jsonb not null default '[]'::jsonb,
  tags jsonb not null default '[]'::jsonb,
  is_featured boolean not null default false,
  is_new boolean not null default false,
  rating numeric(2,1) not null default 0,
  enrollment_count integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.course_progress (
  user_id uuid not null references auth.users(id) on delete cascade,
  course_id text not null references public.courses(id) on delete cascade,
  completed_lesson_ids jsonb not null default '[]'::jsonb,
  completed_lessons integer not null default 0,
  total_study_minutes integer not null default 0,
  last_accessed_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (user_id, course_id)
);

create table if not exists public.bookmarks (
  user_id uuid not null references auth.users(id) on delete cascade,
  lesson_id text not null,
  created_at timestamptz not null default now(),
  primary key (user_id, lesson_id)
);

create table if not exists public.community_posts (
  id uuid primary key default gen_random_uuid(),
  author_id uuid not null references auth.users(id) on delete cascade,
  title text not null check (char_length(title) between 1 and 140),
  content text not null check (char_length(content) between 5 and 10000),
  type text not null default 'discussion',
  tags jsonb not null default '[]'::jsonb,
  course_ids jsonb not null default '[]'::jsonb,
  is_reported boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.community_replies (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.community_posts(id) on delete cascade,
  author_id uuid not null references auth.users(id) on delete cascade,
  parent_reply_id uuid references public.community_replies(id) on delete cascade,
  content text not null check (char_length(content) between 3 and 5000),
  is_accepted_answer boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.post_votes (
  post_id uuid not null references public.community_posts(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  value smallint not null check (value in (-1, 1)),
  created_at timestamptz not null default now(),
  primary key (post_id, user_id)
);

create table if not exists public.reply_votes (
  reply_id uuid not null references public.community_replies(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  value smallint not null check (value in (-1, 1)),
  created_at timestamptz not null default now(),
  primary key (reply_id, user_id)
);

create table if not exists public.daily_challenge_completions (
  user_id uuid not null references auth.users(id) on delete cascade,
  challenge_date date not null,
  score integer not null default 0,
  completed_at timestamptz not null default now(),
  primary key (user_id, challenge_date)
);

alter table public.profiles enable row level security;
alter table public.course_progress enable row level security;
alter table public.bookmarks enable row level security;
alter table public.community_posts enable row level security;
alter table public.community_replies enable row level security;
alter table public.post_votes enable row level security;
alter table public.reply_votes enable row level security;
alter table public.daily_challenge_completions enable row level security;

create policy "profiles are readable" on public.profiles for select using (true);
create policy "users manage their profile" on public.profiles for all using (auth.uid() = id) with check (auth.uid() = id);
create policy "progress belongs to the user" on public.course_progress for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "bookmarks belong to the user" on public.bookmarks for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "posts are readable" on public.community_posts for select using (true);
create policy "authenticated users create posts" on public.community_posts for insert with check (auth.uid() = author_id);
create policy "authors manage posts" on public.community_posts for update using (auth.uid() = author_id) with check (auth.uid() = author_id);
create policy "authors delete posts" on public.community_posts for delete using (auth.uid() = author_id);
create policy "replies are readable" on public.community_replies for select using (true);
create policy "authenticated users create replies" on public.community_replies for insert with check (auth.uid() = author_id);
create policy "authors manage replies" on public.community_replies for update using (auth.uid() = author_id) with check (auth.uid() = author_id);
create policy "authors delete replies" on public.community_replies for delete using (auth.uid() = author_id);
create policy "votes are readable" on public.post_votes for select using (true);
create policy "users manage post votes" on public.post_votes for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "reply votes are readable" on public.reply_votes for select using (true);
create policy "users manage reply votes" on public.reply_votes for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "challenges belong to the user" on public.daily_challenge_completions for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Course catalog is public read-only from the app; content is seeded/admin-managed.
alter table public.courses enable row level security;
create policy "courses are readable" on public.courses for select using (true);
