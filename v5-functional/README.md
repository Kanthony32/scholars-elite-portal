# Scholars Coach Access V5 Functional Starter

This package is the **working version** of the portal starter — not just the preview.

## What is included

- public home page and prospect directory
- public individual player pages
- coach magic-link sign-in screen
- auth callback route that checks an invite whitelist
- blocked access screen for non-invited users
- protected staff dashboard
- admin invite management screen
- public and staff API routes
- Supabase schema + seed SQL
- local seed-data fallback so the UI still runs before Supabase is connected

## Stack

- Next.js App Router
- Supabase Auth + Postgres + RLS
- `@supabase/ssr`

## Setup

1. Install packages

```bash
npm install
```

2. Copy the env file

```bash
cp .env.example .env.local
```

3. Create a Supabase project.
4. Run these SQL files in order:
   - `supabase/001_schema.sql`
   - `supabase/002_seed.sql`
   - `supabase/003_invite_system.sql`
5. Add your project values to `.env.local`.
6. Start the app:

```bash
npm run dev
```

## Required environment variables

- `NEXT_PUBLIC_SUPABASE_URL`
- `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`
- `SUPABASE_SERVICE_ROLE_KEY`
- `NEXT_PUBLIC_SITE_URL`

## Invite-only flow

1. Admin adds coach email to `coach_invites`
2. Coach visits `/sign-in`
3. Supabase sends magic link
4. `/auth/callback` exchanges the code, verifies the invite, and upserts `staff_profiles`
5. If the email is not invited or inactive, the user lands on `/not-authorized`

## Important truth

Without Supabase env vars, the app still renders in **demo mode** so you can review screens and flows.
That is useful for previewing.
It is **not secure mode**.

Real access control only turns on after Supabase is connected.
