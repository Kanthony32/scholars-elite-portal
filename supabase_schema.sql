-- ============================================================
-- SCHOLARS ELITE — FAMILY RECRUITING PORTAL
-- Supabase Schema v1.0
-- Paste this entire file into: Supabase Dashboard → SQL Editor → Run
-- ============================================================


-- ── 1. PROFILES ──────────────────────────────────────────────
-- Extends auth.users. Created automatically on signup via trigger.

create table public.profiles (
  id             uuid references auth.users(id) on delete cascade primary key,
  role           text not null default 'parent' check (role in ('parent', 'staff')),
  athlete_id     text,           -- null until linked; staff leave null
  display_name   text,
  created_at     timestamptz default now()
);

alter table public.profiles enable row level security;

-- Users can read/update their own profile
create policy "profiles: own read"   on profiles for select using (auth.uid() = id);
create policy "profiles: own update" on profiles for update using (auth.uid() = id);
-- Staff can read all profiles (for roster management)
create policy "profiles: staff read all" on profiles for select using (
  exists (select 1 from profiles p where p.id = auth.uid() and p.role = 'staff')
);
-- Staff can update any profile (e.g. link a parent to an athlete)
create policy "profiles: staff update all" on profiles for update using (
  exists (select 1 from profiles p where p.id = auth.uid() and p.role = 'staff')
);


-- ── 2. ATHLETES ───────────────────────────────────────────────
-- Core athlete records. Staff creates; parents + staff both edit.

create table public.athletes (
  id                 text primary key,        -- slug e.g. "ava-london"
  name               text not null,
  grad_year          text,
  position           text,
  height             text,
  archetype          text,
  gpa                text,
  player_level       text default 'PL3',      -- STAFF ONLY field (enforced via app logic + note below)
  strengths          text,
  development_needs  text,
  recruiting_story   text,
  offers             text[] default '{}',
  highlight_link     text,
  visibility_score   int  default 5 check (visibility_score between 0 and 10),
  access_code        text unique,             -- parents use this code at signup e.g. "LONDON2026"
  committed_to       text,                    -- school name once committed
  status             text default 'active' check (status in ('active', 'committed', 'signed', 'inactive')),
  created_at         timestamptz default now(),
  updated_at         timestamptz default now()
);

alter table public.athletes enable row level security;

-- Parents can view their own athlete; staff can view all
create policy "athletes: parent view own" on athletes for select using (
  exists (select 1 from profiles p where p.id = auth.uid() and p.athlete_id = athletes.id)
);
create policy "athletes: staff view all" on athletes for select using (
  exists (select 1 from profiles p where p.id = auth.uid() and p.role = 'staff')
);
-- Parents can update their own athlete (player_level restriction enforced in app)
create policy "athletes: parent update own" on athletes for update using (
  exists (select 1 from profiles p where p.id = auth.uid() and p.athlete_id = athletes.id)
);
-- Staff can insert + update any athlete
create policy "athletes: staff insert" on athletes for insert with check (
  exists (select 1 from profiles p where p.id = auth.uid() and p.role = 'staff')
);
create policy "athletes: staff update all" on athletes for update using (
  exists (select 1 from profiles p where p.id = auth.uid() and p.role = 'staff')
);


-- ── 3. SCHOOL BOARDS ──────────────────────────────────────────
-- One row per athlete-school pairing. The "money tab".

create table public.school_boards (
  id             uuid default gen_random_uuid() primary key,
  athlete_id     text references athletes(id) on delete cascade not null,
  school         text not null,
  conference     text,
  tier           text default 'T3',
  factors        jsonb default '{
    "bbLevel": 5,
    "opportunity": 5,
    "athletic": 5,
    "skill": 5,
    "academic": 5,
    "style": 5,
    "geo": 5,
    "relationship": 5
  }',
  notes          text default '',        -- visible to parents + staff
  staff_notes    text default '',        -- STAFF ONLY (hidden from parent view in app)
  last_contact   date,
  has_offer      boolean default false,
  created_by     uuid references auth.users(id),
  updated_by     uuid references auth.users(id),
  created_at     timestamptz default now(),
  updated_at     timestamptz default now()
);

alter table public.school_boards enable row level security;

-- Read: parent sees own board; staff sees all
create policy "boards: parent select" on school_boards for select using (
  exists (select 1 from profiles p where p.id = auth.uid() and p.athlete_id = school_boards.athlete_id)
);
create policy "boards: staff select all" on school_boards for select using (
  exists (select 1 from profiles p where p.id = auth.uid() and p.role = 'staff')
);
-- Insert: parent for own; staff for any
create policy "boards: parent insert" on school_boards for insert with check (
  exists (select 1 from profiles p where p.id = auth.uid() and p.athlete_id = school_boards.athlete_id)
);
create policy "boards: staff insert" on school_boards for insert with check (
  exists (select 1 from profiles p where p.id = auth.uid() and p.role = 'staff')
);
-- Update: parent for own (staff_notes column blocked via app); staff for any
create policy "boards: parent update" on school_boards for update using (
  exists (select 1 from profiles p where p.id = auth.uid() and p.athlete_id = school_boards.athlete_id)
);
create policy "boards: staff update all" on school_boards for update using (
  exists (select 1 from profiles p where p.id = auth.uid() and p.role = 'staff')
);
-- Delete: parent for own; staff for any
create policy "boards: parent delete" on school_boards for delete using (
  exists (select 1 from profiles p where p.id = auth.uid() and p.athlete_id = school_boards.athlete_id)
);
create policy "boards: staff delete all" on school_boards for delete using (
  exists (select 1 from profiles p where p.id = auth.uid() and p.role = 'staff')
);


-- ── 4. ACTIVITY FEED ──────────────────────────────────────────
-- Running log of recruiting events. Auto-populated by app.

create table public.activity_feed (
  id          uuid default gen_random_uuid() primary key,
  athlete_id  text references athletes(id) on delete cascade not null,
  actor_id    uuid references auth.users(id),
  actor_name  text,                    -- denormalized for display
  type        text not null,           -- see types below
  message     text not null,
  meta        jsonb default '{}',      -- e.g. {"school": "James Madison", "score": 82}
  created_at  timestamptz default now()
);

-- activity types:
-- 'school_added'        → parent/staff added a school to board
-- 'school_removed'      → school removed from board
-- 'score_updated'       → fit factors updated on a school
-- 'offer_received'      → scholarship offer logged
-- 'profile_updated'     → athlete profile fields changed
-- 'player_level_set'    → staff changed PL designation
-- 'committed'           → athlete committed to a school

alter table public.activity_feed enable row level security;

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

-- Auto-create profile row when a new user signs up
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, role, display_name)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'role', 'parent'),
    coalesce(new.raw_user_meta_data->>'display_name', new.email)
  );
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Auto-update updated_at timestamps
create or replace function update_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger athletes_updated_at
  before update on athletes
  for each row execute procedure update_updated_at();

create trigger school_boards_updated_at
  before update on school_boards
  for each row execute procedure update_updated_at();


-- ── 6. SEED DATA ──────────────────────────────────────────────
-- Run AFTER your first staff user has signed up.
-- Replace 'your-staff-user-id' with the actual UUID from auth.users.

-- Insert athletes (staff manages these)
insert into athletes (id, name, grad_year, position, height, archetype, gpa, player_level, strengths, development_needs, recruiting_story, visibility_score, access_code, status)
values
  ('ava-london',      'Ava London',      '2026', 'Wing',    '6''0"',  'Two-way wing / Stretch forward',      '3.4', 'PL2', 'Length, versatility, shooting range',          'Physicality at the rim, defensive intensity',    'Legit HM frame with developing skillset. P4 ceiling if she takes the next step.',             8, 'LONDON2026',  'active'),
  ('kassidy-ahmad',   'Kassidy Ahmad',   '2026', 'Guard',   '5''8"',  'Lead guard / Shot-maker',             '3.6', 'PL3', 'Ball handling, court vision, pull-up J',        'Finishing through contact, off-ball movement',   'High-academic profile with on-court playmaking upside. Mid-major plus ceiling.',              7, 'AHMAD2026',   'active'),
  ('nasiaah-russell', 'Nasiaah Russell', '2026', 'Guard',   '5''6"',  'Combo guard / Switchable defender',   '3.8', 'PL3', 'IQ, defense, shot discipline',                  'Explosiveness, shot creation off dribble',       'Academic-priority recruit. T3 with high academic value is the ideal window.',                 6, 'RUSSELL2026', 'active'),
  ('raegan-wb',       'Raegan Wells-Bradley','2027','Forward','6''1"', 'Stretch forward / Rim runner',        '3.2', 'PL2', 'Motor, positioning, versatility',               'Perimeter shooting consistency',                 'Long-term upside play. Strong P4 ceiling if development hits.',                               7, 'RAEGAN2027',  'active'),
  ('maya-thompson',   'Maya Thompson',   '2026', 'Guard',   '5''5"',  'Lead guard / High IQ',                '3.5', 'PL4', 'Passing, floor management, locker room',        'Athleticism, first step',                        'Elite IQ player. True mid-major fit. Great culture add.',                                     5, 'MAYA2026',    'active'),
  ('jordyn-pierce',   'Jordyn Pierce',   '2027', 'Wing',    '5''10"', 'Athletic / Late bloomer',             '3.1', 'PL3', 'Athleticism, upside, energy',                   'Skill refinement, shooting mechanics',           'High-ceiling prospect. Needs 18 months of development to unlock.',                           6, 'JORDYN2027',  'active'),
  ('taylor-brooks',   'Taylor Brooks',   '2026', 'Post',    '6''2"',  'Undersized post / Rim runner',        '3.3', 'PL4', 'Interior presence, rebounding, energy',         'Facing up, post footwork',                       'True mid-major post. Build active boards at T4 programs.',                                    5, 'TAYLOR2026',  'active');

-- Seed school boards
insert into school_boards (athlete_id, school, conference, tier, factors, notes, has_offer)
values
  -- Ava London
  ('ava-london', 'James Madison', 'Sun Belt', 'T3',
   '{"bbLevel":9,"opportunity":9,"athletic":8,"skill":8,"academic":9,"style":8,"geo":7,"relationship":7}',
   'Best current landing window — mutual interest building.', false),
  ('ava-london', 'Florida State', 'ACC', 'T2',
   '{"bbLevel":8,"opportunity":8,"athletic":8,"skill":7,"academic":8,"style":7,"geo":9,"relationship":6}',
   'Frame + academics fit. No offer yet.', false),
  ('ava-london', 'Oregon', 'Big Ten', 'T2',
   '{"bbLevel":8,"opportunity":7,"athletic":8,"skill":7,"academic":6,"style":6,"geo":4,"relationship":4}',
   'Pacific NW geo gap. Strong bb fit.', false),
  -- Kassidy Ahmad
  ('kassidy-ahmad', 'James Madison', 'Sun Belt', 'T3',
   '{"bbLevel":8,"opportunity":8,"athletic":7,"skill":7,"academic":9,"style":8,"geo":7,"relationship":6}',
   'Academic + bb fit ideal.', false),
  ('kassidy-ahmad', 'FGCU', 'ASUN', 'T3',
   '{"bbLevel":8,"opportunity":8,"athletic":7,"skill":7,"academic":7,"style":7,"geo":9,"relationship":5}',
   'Strong Florida fit. Proximity advantage.', false),
  -- Nasiaah Russell
  ('nasiaah-russell', 'James Madison', 'Sun Belt', 'T3',
   '{"bbLevel":8,"opportunity":7,"athletic":6,"skill":7,"academic":10,"style":8,"geo":7,"relationship":6}',
   'Academic priority — JMU is the bullseye.', false),
  ('nasiaah-russell', 'Belmont', 'MVC', 'T3',
   '{"bbLevel":7,"opportunity":7,"athletic":6,"skill":7,"academic":9,"style":7,"geo":6,"relationship":5}',
   'Academic fit strong. Faith-based culture fit.', false);

-- ── 7. HELPER FUNCTIONS ───────────────────────────────────────

-- Lookup athlete by access code (called during parent signup)
create or replace function get_athlete_by_code(code text)
returns table(id text, name text) as $$
  select id, name from athletes where lower(access_code) = lower(code) limit 1;
$$ language sql security definer;

-- ============================================================
-- SETUP CHECKLIST (after running this schema):
-- 1. Go to Authentication → Settings → Enable email confirmations: OFF (for easier testing)
-- 2. Create your first staff account via the app signup (use staff code: SCHOLARS-STAFF-2026)
-- 3. Run the seed inserts above (you can modify/add athlete records as needed)
-- 4. Share access codes with families (e.g. LONDON2026) for self-service signup
-- ============================================================
