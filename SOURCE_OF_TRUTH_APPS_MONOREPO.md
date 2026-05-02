# Source of Truth — Corfu Map Platform (Apps Monorepo)

**Last updated:** 2026-03-05  
**Repository:** apps monorepo (Flutter)  
**Connects to:** Supabase (LOCAL via CLI), Staging Supabase project, Production Supabase project  
**Rule:** This document is the primary architecture/spec reference for the *apps repo*. The CICD/migrations repo has its own source-of-truth doc.

---

## 1) What this repo contains

A single GitHub repo hosting **three Flutter projects** + a reusable Dart package:

- `shared/` — reusable Dart package (models, repositories, data sources, auth helpers, logging client, utilities)
- `user-app/` — Flutter app for residents (map, civic layers, issues, notifications)
- `owner-app/` — Flutter app (web-first) for business/org owners (claim & manage listings, jobs, events)
- `admin-app/` — Flutter app (web-first) for admins (moderation, disputes, KPIs, evidence exports)

> Note: folder names may differ (e.g. `vvapp`, `vvapp-admin-cms`). The intent above is the contract.

---

## 2) Core product surfaces (role-based)

### 2.1 User app (Resident)
Primary experience. Contains:
- **Civic map**: places/landmarks/orgs, events (incl. protests/routes), hiring postings
- **Issues map**: point + area-wide issues (polygons), check-ins, confidence
- **Personalization**: Home pin + Saved places + notification preferences
- **Privacy**: phone-verified accounts, publicly anonymous (no usernames/profiles; optional tier badge)
- **GDPR**: in-app “Delete account” → calls server-side deletion/anonymization

### 2.2 Owner app (Business/Org Owner)
Self-management experience. Contains:
- Claim/ownership workflow for places/org profiles
- Edit listing details (hours, contact, images)
- Post/manage events and job postings
- (Later) promotion tools (spotlight weeks), basic analytics

### 2.3 Admin app (Admin)
Operations and governance. Contains:
- Moderation queues (new places, edits, reports)
- Dispute handling (claim disputes, content disputes)
- Merges (duplicate report/duplicate place proposals)
- Enforcement (warnings, bans, restricted mode)
- KPIs + evidence pack exports (PDF/CSV) (future screens allowed even if data exists first)

---

## 3) Shared package contract (`shared/`)

### 3.1 What must live in `shared/`
- Domain models/entities for:
  - issues/reports, geometries, check-ins
  - places, events, jobs, claims (even if owner/admin apps come later)
  - user settings (notifications, home pin, saved places)
- Repositories/data sources for Supabase:
  - tables, RPC calls, storage access patterns (signed URLs)
- Cross-cutting concerns:
  - error handling + error logging client
  - audit event tagging (client-side metadata only; DB triggers handle writes)
  - encryption helpers (for any client-side protected fields if used)
  - environment banner helpers (LOCAL/DEV/STAGING/PROD)

### 3.2 What must NOT live in `shared/`
- Supabase **service role** key
- Any migration SQL
- Any hard-coded environment URLs/keys (provided by host apps)

### 3.3 Supabase client injection
Host app constructs Supabase client from env (`SUPABASE_URL`, `SUPABASE_ANON_KEY`) and passes it to `shared`.

---

## 4) Environment strategy (apps)

### 4.1 Environments
- **LOCAL**: `npx supabase start` (Docker)
- **STAGING**: hosted Supabase project (staging)
- **PROD**: hosted Supabase project (production)

### 4.2 How apps choose env
Each app loads:
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
via `--dart-define` or `env.json`.

**Never** ship service role in Flutter apps.

### 4.3 Keys
- User/Owner/Admin apps use **anon key** only
- Elevated privileges happen through **auth + RLS role checks**, not special keys

---

## 5) Auth, roles, and permissions

### 5.1 Auth
- Phone OTP required for write actions (posting/claiming/verifying)

### 5.2 Roles (DB-backed)
The DB has a role enum (legacy may be `admin/tourist/tour_guide`). For this platform, apps assume:
- `resident`
- `owner`
- `admin`

Final role enum values and migration plan live in the CICD repo.

### 5.3 High-level permission intent
- Resident: create reports/check-ins; submit places/events/jobs as proposals; edit own settings; no deletes.
- Owner: edit only claimed places/events/jobs; no access to enforcement/audit tables.
- Admin: moderate/approve/reject/ban via RLS; avoid deletes by default.

---

## 6) Maps & geospatial behavior

### 6.1 Geometry types in UI
- Point (pin)
- Polygon (area-wide issues, some events)
- Polyline (protest route; later corridor issues)

### 6.2 Navigation
MVP can deep-link to external navigation. Future: avoid/warn zones (requires spatial queries / PostGIS).

---

## 7) Notifications (push) and user controls

### 7.1 Notification sources
- Followed reports (status updates)
- Proximity alerts for:
  - **Home pin** (pin + radius)
  - **Saved places** (private list)

### 7.2 Controls
- Category filters, severity toggle (all vs severe-only)
- Quiet hours
- Opt-in/out per location

### 7.3 Privacy
No public exposure of home/saved places. Store privacy-preserving tokens where possible.

---

## 8) GDPR account deletion (apps responsibilities)

- Provide Settings → Delete account in user app (and later owner/admin where relevant).
- Client calls server-side function (e.g., `delete_user_account`).
- Client must clear local sessions/tokens and unregister push token.

---

## 9) Repo structure (recommended)

```
root/
  shared/
  user-app/
  owner-app/
  admin-app/
  docs/
```

Each app has its own `pubspec.yaml`, env config, and platform folders.

---

## 10) Definition of Done for the apps repo
- All environments configurable via env injection
- No service role key in apps
- Shared package used for all Supabase calls
- Phone verification gates all writes
- Delete account flow wired to server-side deletion
