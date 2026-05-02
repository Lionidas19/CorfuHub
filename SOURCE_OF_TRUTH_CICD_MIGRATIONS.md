# Source of Truth — Corfu Map Platform (CICD / Migrations Repo)

**Last updated:** 2026-03-05  
**Repository:** CICD + Supabase migrations  
**Owns:** schema, RLS, triggers/functions, env promotion, type generation contract

---

## 1) What this repo contains

This repo is the source of truth for:
- Supabase SQL migrations (schema + required seed data)
- RLS policies and helper functions (e.g., `public.is_admin()`)
- Audit/error logging infrastructure (triggers + RPCs)
- CI/CD pipelines:
  - local validation using Supabase CLI
  - staging deployment
  - production deployment
- Schema contract artifacts (generated types / schema snapshots)

It does **not** contain Flutter app code.

---

## 2) Environment strategy (DB)

### 2.1 Environments
- LOCAL: Supabase CLI (`npx supabase start`)
- STAGING: hosted Supabase project
- PROD: hosted Supabase project

### 2.2 Promotion flow (required)
1. Run migrations locally (CLI)
2. Run automated checks/tests (RLS smoke tests, RPC existence, audit triggers present)
3. Deploy to staging
4. Validate staging
5. Deploy to prod (manual approval recommended)

---

## 3) Keys & security rules

- Service role key is allowed only in CI/Edge Functions/server tools.
- Flutter apps use anon key only.
- Admin powers are granted via roles + RLS, not keys.

---

## 4) Roles model (DB)

Legacy enum may include `admin/tourist/tour_guide`. Target roles for this platform:
- `resident`
- `owner`
- `admin`

Provide a safe migration plan to add/rename roles, set default role to `resident`, and keep `public.is_admin()` authoritative.

---

## 5) Ownership / claim model (DB)

To support owner app:
- Define claimable entities: `places` (or existing `locations`)
- Define relationship tables:
  - `place_claims(place_id, owner_user_id, status, created_at, approved_at, ...)`
  - optional `place_managers(place_id, user_id, role)`
- Owner edit rights come from approved claims, not role alone.

---

## 6) RLS policy principles

### 6.1 Resident
- Read public data
- Insert reports/check-ins
- Insert proposals for places/events/jobs (if used)
- CRUD only own settings (home pin, saved places, notification prefs)
- No deletes in public tables

### 6.2 Owner
- Select/edit only claimed rows
- No access to enforcement/audit tables

### 6.3 Admin
- Uses anon key + auth; elevated via `public.is_admin()`
- Can approve/reject/moderate/enforce
- Avoid deletes by default (use archival/anonymization)

---

## 7) Audit logs & analytics

Audit infra exists:
- `public.audit_events`
- `public.audit_trigger_func()`
- `public.log_audit_event(...)`
- `public.log_error_event(...)`

Requirements:
- Triggers on all core domain tables (reports, checkins, places, events, jobs, claims, user settings, enforcement)
- Audit payload excludes PII

---

## 8) Geospatial support

Current numeric lat/long is ok for simple MVP, but platform needs polygons/routes:
- Enable PostGIS in local + staging + prod
- Use geometry/geography columns + GiST indexes for point/polygon/polyline
- Provide helper RPCs for proximity and intersection queries

---

## 9) GDPR deletion / anonymization

Apps call a server-side function (e.g., `delete_user_account`). It should:
- remove auth identifiers where applicable
- anonymize PII in `public.users`
- delete push tokens
- preserve audit rows pseudonymously (non-identifying actor key)
- handle storage objects deletion/takedown where required

---

## 10) Schema contract between repos

- Migrations committed + contract artifact generated in CI (types/snapshot)
- Recommend adding `schema_version` table or explicit schema snapshot version
- Communicate compatibility: “DB schema vX requires shared package ≥ vY”

---

## 11) Definition of Done for CICD repo
- Local migrations run cleanly
- Staging/prod apply same migration set
- RLS enforces role boundaries
- Audit triggers present
- delete_user_account implemented + tested
- Contract artifact generated + versioned
