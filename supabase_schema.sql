-- ============================================================
-- SCHOLARS ELITE — FAMILY RECRUITING PORTAL
-- Supabase Schema v1.1 — SAFE VERSION (run on existing DB)
-- Uses IF NOT EXISTS throughout — safe to run multiple times
-- ============================================================


-- ── 1. PROFILES ──────────────────────────────────────────────
create table if not exists public.profiles (
  id             uuid references auth.users(id) on delete cascade primary key,
  role           text not null default 'parent' check (role in ('parent', 'staff')),
  athlete_id     text,
  display_name   text,
  created_at     timestamptz default now()
);

alter table public.profiles enable row level security;

drop policy if exists "profiles: own read"        on profiles;
drop policy if exists "profiles: own update"      on profiles;
drop policy if exists "profiles: staff read all"  on profiles;
drop policy if exists "profiles: staff update all" on profiles;

create policy "profiles: own read"   on profiles for select using (auth.uid() = id);
create policy "profiles: own update" on profiles for update using (auth.uid() = id);
create policy "profiles: staff read all" on profiles for select using (
  exists (select 1 from profiles p where p.id = auth.uid() and p.role = 'staff')
);
create policy "profiles: staff update all" on profiles for update using (
  exists (select 1 from profiles p where p.id = auth.uid() and p.role = 'staff')
);


-- ── 2. ATHLETES ───────────────────────────────────────────────
create table if not exists public.athletes (
  id                 text primary key,
  name               text not null,
  grad_year          text,
  position           text,
  height             text,
  archetype          text,
  gpa                text,
  player_level       text default 'PL3',
  strengths          text,
  development_needs  text,
  recruiting_story   text,
  offers             text[] default '{}',
  highlight_link     text,
  visibility_score   int  default 5 check (visibility_score between 0 and 10),
  access_code        text unique,
  committed_to       text,
  status             text default 'active' check (status in ('active', 'committed', 'signed', 'inactive')),
  created_at         timestamptz default now(),
  updated_at         timestamptz default now()
);

alter table public.athletes enable row level security;

drop policy if exists "athletes: parent view own"   on athletes;
drop policy if exists "athletes: staff view all"    on athletes;
drop policy if exists "athletes: parent update own" on athletes;
drop policy if exists "athletes: staff insert"      on athletes;
drop policy if exists "athletes: staff update all"  on athletes;

create policy "athletes: parent view own" on athletes for select using (
  exists (select 1 from profiles p where p.id = auth.uid() and p.athlete_id = athletes.id)
);
create policy "athletes: staff view all" on athletes for select using (
  exists (select 1 from profiles p where p.id = auth.uid() and p.role = 'staff')
);
create policy "athletes: parent update own" on athletes for update using (
  exists (select 1 from profiles p where p.id = auth.uid() and p.athlete_id = athletes.id)
);
create policy "athletes: staff insert" on athletes for insert with check (
  exists (select 1 from profiles p where p.id = auth.uid() and p.role = 'staff')
);
create policy "athletes: staff update all" on athletes for update using (
  exists (select 1 from profiles p where p.id = auth.uid() and p.role = 'staff')
);


-- ── 3. SCHOOL BOARDS ──────────────────────────────────────────
create table if not exists public.school_boards (
  id             uuid default gen_random_uuid() primary key,
  athlete_id     text references athletes(id) on delete cascade not null,
  school         text not null,
  conference     text,
  tier           text default 'T3',
  factors        jsonb default '{"bbLevel":5,"opportunity":5,"athletic":5,"skill":5,"academic":5,"style":5,"geo":5,"relationship":5}',
  notes          text default '',
  staff_notes    text default '',
  last_contact   date,
  has_offer      boolean default false,
  created_by     uuid references auth.users(id),
  updated_by     uuid references auth.users(id),
  created_at     timestamptz default now(),
  updated_at     timestamptz default now()
);

alter table public.school_boards enable row level security;

drop policy if exists "boards: parent select"    on school_boards;
drop policy if exists "boards: staff select all" on school_boards;
drop policy if exists "boards: parent insert"    on school_boards;
drop policy if exists "boards: staff insert"     on school_boards;
drop policy if exists "boards: parent update"    on school_boards;
drop policy if exists "boards: staff update all" on school_boards;
drop policy if exists "boards: parent delete"    on school_boards;
drop policy if exists "boards: staff delete all" on school_boards;

create policy "boards: parent select" on school_boards for select using (
  exists (select 1 from profiles p where p.id = auth.uid() and p.athlete_id = school_boards.athlete_id)
);
create policy "boards: staff select all" on school_boards for select using (
  exists (select 1 from profiles p where p.id = auth.uid() and p.role = 'staff')
);
create policy "boards: parent insert" on school_boards for insert with check (
  exists (select 1 from profiles p where p.id = auth.uid() and p.athlete_id = school_boards.athlete_id)
);
create policy "boards: staff insert" on school_boards for insert with check (
  exists (select 1 from profiles p where p.id = auth.uid() and p.role = 'staff')
);
create policy "boards: parent update" on school_boards for update using (
  exists (select 1 from profiles p where p.id = auth.uid() and p.athlete_id = school_boards.athlete_id)
);
create policy "boards: staff update all" on school_boards for update using (
  exists (select 1 from profiles p where p.id = auth.uid() and p.role = 'staff')
);
create policy "boards: parent delete" on school_boards for delete using (
  exists (select 1 from profiles p where p.id = auth.uid() and p.athlete_id = school_boards.athlete_id)
);
create policy "boards: staff delete all" on school_boards for delete using (
  exists (select 1 from profiles p where p.id = auth.uid() and p.role = 'staff')
);


-- ── 4. ACTIVITY FEED ──────────────────────────────────────────
create table if not exists public.activity_feed (
  id          uuid default gen_random_uuid() primary key,
  athlete_id  text references athletes(id) on delete cascade not null,
  actor_id    uuid references auth.users(id),
  actor_name  text,
  type        text not null,
  message     text not null,
  meta        jsonb default '{}',
  created_at  timestamptz default now()
);

alter table public.activity_feed enable row level security;

drop policy if exists "feed: parent view own" on activity_feed;
drop policy if exists "feed: staff view all"  on activity_feed;
drop policy if exists "feed: parent insert"   on activity_feed;
drop policy if exists "feed: staff insert"    on activity_feed;

create policy "feed: parent view own" on activity_feed for select using (
  exists (select 1 from profiles p where p.id = auth.uid() and p.athlete_id = activity_feed.athlete_id)
);
create policy "feed: staff view all" on activity_feed for select using (
  exists (select 1 from profiles p where p.id = auth.uid() and p.role = 'staff')
);
create policy "feed: parent insert" on activity_feed for insert with check (
  exists (select 1 from profiles p where p.id = auth.uid() and p.athlete_id = activity_feed.athlete_id)
);
create policy "feed: staff insert" on activity_feed for insert with check (
  exists (select 1 from profiles p where p.id = auth.uid() and p.role = 'staff')
);


-- ── 5. TRIGGERS ───────────────────────────────────────────────
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, role, display_name)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'role', 'parent'),
    coalesce(new.raw_user_meta_data->>'display_name', new.email)
  )
  on conflict (id) do nothing;
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

create or replace function update_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists athletes_updated_at    on athletes;
drop trigger if exists school_boards_updated_at on school_boards;

create trigger athletes_updated_at
  before update on athletes
  for each row execute procedure update_updated_at();

create trigger school_boards_updated_at
  before update on school_boards
  for each row execute procedure update_updated_at();


-- ── 6. HELPER FUNCTION ────────────────────────────────────────
create or replace function get_athlete_by_code(code text)
returns table(id text, name text) as $$
  select id, name from athletes
  where lower(access_code) = lower(code)
    and status = 'active'
  limit 1;
$$ language sql security definer;


-- ── 7. SEED ATHLETES (safe — skips if already exists) ─────────
insert into athletes (id, name, grad_year, position, height, archetype, gpa, player_level, strengths, development_needs, recruiting_story, visibility_score, access_code, status)
values
  ('kassidy-ahmad',   'Kassidy Ahmad',       '2026', 'Guard',   '5''8"',  'Lead guard / Shot-maker',             '3.6', 'PL3', 'Ball handling, court vision, pull-up J',        'Finishing through contact, off-ball movement',   'High-academic profile with on-court playmaking upside. Mid-major plus ceiling.',              7, 'AHMAD2026',   'active'),
  ('nasiaah-russell', 'Nasiaah Russell',     '2026', 'Guard',   '5''6"',  'Combo guard / Switchable defender',   '3.8', 'PL3', 'IQ, defense, shot discipline',                  'Explosiveness, shot creation off dribble',       'Academic-priority recruit. T3 with high academic value is the ideal window.',                 6, 'RUSSELL2026', 'active'),
  ('raegan-wb',       'Raegan Wells-Bradley','2027', 'Forward', '6''1"',  'Stretch forward / Rim runner',        '3.2', 'PL2', 'Motor, positioning, versatility',               'Perimeter shooting consistency',                 'Long-term upside play. Strong P4 ceiling if development hits.',                               7, 'RAEGAN2027',  'active'),
  ('maya-thompson',   'Maya Thompson',       '2026', 'Guard',   '5''5"',  'Lead guard / High IQ',                '3.5', 'PL4', 'Passing, floor management, locker room',        'Athleticism, first step',                        'Elite IQ player. True mid-major fit. Great culture add.',                                     5, 'MAYA2026',    'active'),
  ('jordyn-pierce',   'Jordyn Pierce',       '2027', 'Wing',    '5''10"', 'Athletic / Late bloomer',             '3.1', 'PL3', 'Athleticism, upside, energy',                   'Skill refinement, shooting mechanics',           'High-ceiling prospect. Needs 18 months of development to unlock.',                           6, 'JORDYN2027',  'active'),
  ('taylor-brooks',   'Taylor Brooks',       '2026', 'Post',    '6''2"',  'Undersized post / Rim runner',        '3.3', 'PL4', 'Interior presence, rebounding, energy',         'Facing up, post footwork',                       'True mid-major post. Build active boards at T4 programs.',                                    5, 'TAYLOR2026',  'active')
on conflict (id) do nothing;

-- ============================================================
-- SUCCESS — all tables, policies, triggers, and seed data ready
-- Next step: go to Database → Webhooks and create notify-parents
-- ============================================================
