-- ============================================================
-- SCHOLARS ELITE — RLS INFINITE RECURSION FIX
-- Run this in Supabase SQL Editor
-- Fixes: "infinite recursion detected in policy for relation profiles"
-- ============================================================

-- Step 1: Drop the recursive policies on profiles
drop policy if exists "profiles: staff read all"   on profiles;
drop policy if exists "profiles: staff update all" on profiles;

-- Step 2: Create a security definer function that checks role
-- without triggering RLS (bypasses the policy check)
create or replace function public.get_my_role()
returns text as $$
  select role from public.profiles where id = auth.uid() limit 1;
$$ language sql security definer stable;

-- Step 3: Recreate staff policies using the function instead
-- of a subquery that causes recursion
create policy "profiles: staff read all"
  on profiles for select
  using (public.get_my_role() = 'staff');

create policy "profiles: staff update all"
  on profiles for update
  using (public.get_my_role() = 'staff');

-- Step 4: Fix the same recursion on other tables too
-- (they all have the same pattern — replace subquery with function)

-- Athletes
drop policy if exists "athletes: parent view own"   on athletes;
drop policy if exists "athletes: staff view all"    on athletes;
drop policy if exists "athletes: parent update own" on athletes;
drop policy if exists "athletes: staff insert"      on athletes;
drop policy if exists "athletes: staff update all"  on athletes;

create policy "athletes: parent view own" on athletes for select using (
  (select athlete_id from profiles where id = auth.uid()) = athletes.id
);
create policy "athletes: staff view all" on athletes for select using (
  public.get_my_role() = 'staff'
);
create policy "athletes: parent update own" on athletes for update using (
  (select athlete_id from profiles where id = auth.uid()) = athletes.id
);
create policy "athletes: staff insert" on athletes for insert with check (
  public.get_my_role() = 'staff'
);
create policy "athletes: staff update all" on athletes for update using (
  public.get_my_role() = 'staff'
);

-- School boards
drop policy if exists "boards: parent select"    on school_boards;
drop policy if exists "boards: staff select all" on school_boards;
drop policy if exists "boards: parent insert"    on school_boards;
drop policy if exists "boards: staff insert"     on school_boards;
drop policy if exists "boards: parent update"    on school_boards;
drop policy if exists "boards: staff update all" on school_boards;
drop policy if exists "boards: parent delete"    on school_boards;
drop policy if exists "boards: staff delete all" on school_boards;

create policy "boards: parent select" on school_boards for select using (
  (select athlete_id from profiles where id = auth.uid()) = school_boards.athlete_id
);
create policy "boards: staff select all" on school_boards for select using (
  public.get_my_role() = 'staff'
);
create policy "boards: parent insert" on school_boards for insert with check (
  (select athlete_id from profiles where id = auth.uid()) = school_boards.athlete_id
);
create policy "boards: staff insert" on school_boards for insert with check (
  public.get_my_role() = 'staff'
);
create policy "boards: parent update" on school_boards for update using (
  (select athlete_id from profiles where id = auth.uid()) = school_boards.athlete_id
);
create policy "boards: staff update all" on school_boards for update using (
  public.get_my_role() = 'staff'
);
create policy "boards: parent delete" on school_boards for delete using (
  (select athlete_id from profiles where id = auth.uid()) = school_boards.athlete_id
);
create policy "boards: staff delete all" on school_boards for delete using (
  public.get_my_role() = 'staff'
);

-- Activity feed
drop policy if exists "feed: parent view own" on activity_feed;
drop policy if exists "feed: staff view all"  on activity_feed;
drop policy if exists "feed: parent insert"   on activity_feed;
drop policy if exists "feed: staff insert"    on activity_feed;

create policy "feed: parent view own" on activity_feed for select using (
  (select athlete_id from profiles where id = auth.uid()) = activity_feed.athlete_id
);
create policy "feed: staff view all" on activity_feed for select using (
  public.get_my_role() = 'staff'
);
create policy "feed: parent insert" on activity_feed for insert with check (
  (select athlete_id from profiles where id = auth.uid()) = activity_feed.athlete_id
);
create policy "feed: staff insert" on activity_feed for insert with check (
  public.get_my_role() = 'staff'
);

-- ============================================================
-- Done. Go back to the portal and connect — it should work now.
-- ============================================================
