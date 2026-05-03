# Source of Truth — Corfu Map Platform (CICD / Migrations Repo)

**Last updated:** 2026-03-05  
**Repo:** CICD + Supabase migrations  
**Owns:** schema, RLS, triggers/functions, seed, environment promotion, contract artifacts  
**Environments:** LOCAL (CLI) → STAGING → PROD

> This document contains the **complete backend/infrastructure scope from day 1** so the schema and RLS can be built once to support all apps (resident/owner/admin).

---

## 1) Responsibilities of this repo
- SQL migrations (schema + required seed)
- RLS policies and helper functions (e.g., `public.is_admin()`)
- Audit/error logging infra (audit tables, triggers, RPCs)
- Storage bucket policies (if managed via SQL)
- CI/CD pipeline local→staging→prod
- Contract artifacts (generated types/snapshots) to prevent drift

---

## 2) Environment strategy
- LOCAL: `npx supabase start` and apply migrations
- STAGING: deploy migrations, validate, run smoke tests
- PROD: deploy after approval

---

## 3) Key rules
- service role key allowed only in CI/Edge Functions/server tooling
- Flutter apps use anon key only
- Admin privileges come from role+RLS (`public.is_admin()`), not keys

---

## 4) Roles model (DB)
Legacy enum may include `admin/tourist/tour_guide`. Target roles:
- `resident`
- `owner`
- `admin`

Requirements:
- safe migration plan to add/rename roles
- default role should be `resident`
- maintain `public.is_admin()` as authoritative admin check

---

## 5) Day-1 schema modules (complete)

### 5.1 Users and trust/enforcement
- `public.users` (mirrored from auth)
- Trust tier storage (tier-only public exposure allowed via view/RPC):
  - `user_trust(user_id, tier, score_optional, updated_at)`
- Enforcement:
  - `enforcement(user_id, strikes, ban_until, restricted_until, updated_at)`

### 5.2 Places/landmarks/orgs (civic directory)
- `places` (or extend existing `locations`)
  - geometry: point (and optional polygon later)
  - lifecycle: pending/active/claimed/disputed/archived
  - created_by, updated_by, timestamps
- `place_edit_proposals` (optional but recommended to avoid direct edits)
- `place_reports` (flag wrong info/spam/closed)

### 5.3 Claims and delegation
- `place_claims(place_id, claimant_user_id, status, created_at, reviewed_at, reviewed_by)`
- optional `place_managers(place_id, user_id, role)`

Rule: owner editing rights come from **approved claim**, not role alone.

### 5.4 Events (including protests/routes)
- `events`
  - host_type: business/admin/individual/org
  - geometry_type: point|polygon|polyline
  - geometry payload
  - start/end time, expiration
- optional `event_routes` if you want separate route storage
- optional `event_edit_proposals`

### 5.5 Hiring/jobs
- `jobs`
  - place_id or org_id
  - title/description/contact
  - expires_at
  - status: active/expired/removed

### 5.6 Issues (reports/disruptions)
- `reports` (issues)
  - geometry_type: point|polygon (polyline reserved)
  - geometry payload
  - category, severity, status
  - created_by, timestamps
- `report_media`
- `checkins` (affected/still_broken/etc.)
- `report_merges` (history)

### 5.7 Personalization and notifications
- `user_settings` (notification prefs, quiet hours)
- `home_pin` (token + radius + optional encrypted coords)
- `saved_places` (private list)

### 5.8 Provider proof-of-work (full)
- `providers` (profile)
- `report_fix_claims` (after photos, job code/receipt pointer, status pending/verified/disputed)
- `provider_portfolio` (derived view)

### 5.9 Promotions (full)
- `spotlight_weeks` (schedule by category + area)
- `spotlight_entries` (who is featured, paid/free slots, dates)
- `freelancers` directory (non-map) + optional promotions links

---

## 6) RLS policy principles (complete)

### 6.1 Resident
- public read of `active` civic data and public issues
- insert reports/checkins
- insert place/event/job proposals (if allowed)
- CRUD only own settings/home_pin/saved_places
- no deletes on public tables

### 6.2 Owner
- can edit only approved-claim rows (places/events/jobs tied to their claim)
- cannot access enforcement/audit tables
- cannot alter issues status

### 6.3 Admin
- role-based access via `public.is_admin()`
- can approve/reject claims and proposals
- can moderate, merge, enforce
- avoid hard deletes; use archival/anonymization

---

## 7) Audit logs & analytics (day-1)
Existing infra:
- `public.audit_events`
- `public.audit_trigger_func()`
- `public.log_audit_event(...)` / `public.log_error_event(...)`

Requirements:
- triggers on all core domain tables listed above
- audit payload must exclude PII (phone, private coords, encrypted blobs)
- provide KPI views/RPCs:
  - top issue categories/areas
  - severe counts
  - backlog age buckets
  - area-wide check-in density
  - spam/duplicate rates
- evidence pack export helpers (view/RPC) with anonymization

---

## 8) Geospatial support (day-1 requirement)
Enable PostGIS in LOCAL/STAGING/PROD.

Use:
- points: `geography(Point,4326)` or `geometry(Point,4326)` + GiST index
- polygons: `geometry(Polygon,4326)` + GiST index
- polylines: `geometry(LineString,4326)` + GiST index

Provide helper RPCs/views:
- within radius
- contains point
- intersects buffer
- (future) route intersects avoid zones

---

## 9) GDPR deletion/anonymization (day-1)
Apps call server-side function (e.g., `delete_user_account`) implemented here.

Deletion must:
- remove auth identifiers as appropriate
- anonymize PII in `public.users`
- delete push tokens + sessions
- preserve audit events pseudonymously (keep non-identifying actor key for joins)
- handle storage object deletion/takedown where required
- define backup retention window and purge expectations

---

## 10) Schema contract between repos
- migrations committed
- contract artifact generated in CI (types/snapshot)
- recommend `schema_version` table and CI compatibility checks
- document compatibility: “DB schema vX requires shared package ≥ vY”

---

## 11) Done definitions (CICD repo)
- migrations apply cleanly locally
- staging/prod apply same migration set
- RLS matrix enforced
- PostGIS enabled and indexed
- audit triggers present on required tables
- delete_user_account implemented + tested
- contract artifact generated + versioned
