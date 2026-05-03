# Source of Truth — Corfu Map Platform (Apps Monorepo)

**Last updated:** 2026-03-05  
**Repo:** Apps monorepo (Flutter)  
**Apps:** Resident/User app + Owner app + Admin app  
**Shared:** Reusable Dart package (`shared/`) containing all Supabase access + domain logic  
**Backend:** Supabase (LOCAL via CLI, hosted STAGING project, hosted PROD project)  
**Security rule:** Flutter apps use **SUPABASE_URL + SUPABASE_ANON_KEY only** (never service role).

> This document contains the **complete platform scope from day 1** so infrastructure (schema + RLS + logging + storage conventions) can be designed once and reused across all apps.

---

## 1) Product overview

A locals-first platform for Corfu built around a map with two primary resident-facing modes:
1) **Civic Map** — community directory + events + hiring + community/org profiles + claimable listings (Google-Maps-like, community-managed)
2) **Issues Map** — structured civic issue reporting + area-wide disruptions + confidence signals + evidence-grade analytics

Admin and Owner experiences are separate apps but use the same backend and shared package.

---

## 2) Repositories and projects in this repo

### 2.1 Monorepo layout (recommended)
```
root/
  shared/                 # reusable Dart package
  user-app/               # Flutter: resident app (mobile-first)
  owner-app/              # Flutter: owner portal (web-first, optional mobile later)
  admin-app/              # Flutter: admin portal (web-first)
  docs/
```

### 2.2 Shared package contract (must be enforced)
`shared/` must contain:
- domain models/entities and enums (reports, places, events, jobs, claims, check-ins, trust tiers, notification prefs)
- repository layer for all Supabase tables and RPCs (no migrations here)
- storage helpers (signed URLs), upload pipeline helpers (EXIF stripping support)
- logging client (calls to `log_error_event` RPC etc. — no PII)
- environment banner helpers (LOCAL/STAGING/PROD)
- auth helpers (phone OTP flows, session management)

`shared/` must NOT contain:
- service role key
- migrations SQL
- hardcoded env URLs/keys

Supabase client injection:
- each host app constructs client from env and passes into `shared`.

---

## 3) App surfaces and responsibilities

### 3.1 Resident/User app (mobile-first)
Contains:
- **Civic Map mode**
  - Places/landmarks/org profiles (community-addable)
  - Claimable listings (owners/org managers can claim)
  - Events (incl. protests with route geometry)
  - Hiring posts (“This place is hiring”)
  - Saved places (private)
  - External navigation deep-link
- **Issues Map mode**
  - Point issues + area-wide polygon issues
  - Check-ins (“I’m affected”, “still broken”) + confidence indicator
  - Follow report updates
  - Proximity alerts around Home pin & Saved places

### 3.2 Owner app (web-first)
Contains:
- Claim listings (places/orgs) and manage them after approval
- Edit listing: hours, contact, photos, categories, descriptions
- Create/manage events and hiring posts for claimed entities
- (Full) Promotions:
  - **Promo weeks / spotlight** scheduling participation (category-based rotations)
  - Basic analytics: views, taps, contact requests

### 3.3 Admin app (web-first)
Contains:
- Moderation queues:
  - new place submissions
  - edits/proposals
  - claim approvals and disputes
  - events/jobs approvals (if required)
  - issue report duplicates/merges
- Enforcement:
  - warnings, bans, restricted mode
- Analytics:
  - KPI dashboard
  - Evidence pack exports (PDF/CSV) with anonymization
- Master data:
  - categories, severities, area definitions (villages/neighborhoods), spotlight schedules

---

## 4) Privacy, anonymity, and trust (non-social)

### 4.1 Public anonymity
- Phone verification is required to contribute.
- Public UI shows **no identities** (no usernames/profiles).
- Optional **tier badge only** (New/Trusted/Steward), without identity.

### 4.2 Trust tiers (public badge)
- **New**
- **Trusted**
- **Steward**

Rules:
- Everyone starts at a **base trust floor** and can fall back to it but never below.
- Trust affects weighting and privileges, not popularity.

### 4.3 Enforcement is separate from trust
Abuse is handled via:
- rate limits
- warnings → temporary bans (increasing durations)
- restricted mode (submissions require review)

No permanent public “marks.”

### 4.4 Confidence indicator per issue
Issues and disruptions display **Low / Medium / High** confidence derived from:
- check-in count + recency
- evidence photo rate
- tier weighting multipliers (server-defined)
- geometry type (point vs polygon)

---

## 5) Core domain modules (day-1 infrastructure scope)

This section defines everything the backend must support from the start.

### 5.1 Civic Map: places/landmarks/orgs (claimable)
- Community can submit a new place/landmark/org profile.
- Listings lifecycle: `pending → active → claimed → disputed → archived`
- Owners/org managers can claim and then manage their own listing.

### 5.2 Events
- Events can be hosted by:
  - businesses
  - island administration
  - individuals (phone-verified)
  - community orgs (e.g., philharmonics)
- Event geometry:
  - point (single venue)
  - polygon (festival area)
  - polyline (protest route)
- Events have start/end time and automatic expiration.

### 5.3 Hiring / jobs
- A place/org can post “hiring” listings.
- Jobs expire automatically and can be reported as stale/spam.

### 5.4 Issues Map: reports + area-wide disruptions
- Issue geometry:
  - point (pin)
  - polygon (area-wide)
  - polyline reserved for future “corridor issues” (roadworks)
- Check-ins/verifications feed confidence.

### 5.5 Provider “proof of work” (full)
- Providers can claim “fixed this” with evidence:
  - after photo required
  - job code / receipt proof optional
- Provider can only mark **Fixed (pending verification)**, never resolved.
- Verification comes from reporter/community/admin.

### 5.6 Community directory promotions (full)
- **Promo weeks / spotlight** by category (restaurants week, trades week, etc.)
- Promotions appear only in Civic Map/Directory contexts, not in Issues.

### 5.7 Freelancers/remote services directory (full)
- Visible in a directory/list view (not plotted on the map).
- Contact info visible; optional “contact via app form.”
- Can be included in promo weeks.

---

## 6) Notifications and personalization (day-1)

### 6.1 Home pin + Saved places
- Users can set a private Home pin and multiple Saved places.
- Store privacy-preserving location tokens + radius (optionally encrypted coords).

### 6.2 Notification types
- Followed issue updates
- New issues near Home/Saved places (opt-in)
- New events near Saved places (optional)
- Protests near Saved places (optional)
- Hiring posts near Saved places (optional)

### 6.3 Notification controls
- category filters
- severe-only toggle
- quiet hours
- per-location toggles

---

## 7) Media/storage rules
- User uploads (issue photos, evidence photos) go to private storage buckets.
- Serve media via signed URLs.
- Strip EXIF metadata before or during upload.
- Support takedown/removal for GDPR/personal data requests.

---

## 8) Navigation
- MVP: deep-link to external navigation (Google/Apple) from any place/event/issue.
- Future: warn/avoid routes intersecting high-confidence issue polygons (requires geospatial queries).

---

## 9) Monetization boundaries (locals-first)
- Donations (one-time + monthly supporter)
- Owner/provider subscriptions for enhanced listing management and promotions
- Spotlight/promo weeks (directory only)
- **Never** allow payment to affect issue status/visibility (“pay-to-resolve” is prohibited)

---

## 10) Done definitions (apps repo)
- All Supabase interactions go through `shared/` repositories
- No service role key in apps
- Public anonymity enforced in UI
- Phone OTP required for writes
- Home pin + Saved places implemented with editable notification preferences
- Offline drafts for issues (minimum)
- Delete account triggers server-side anonymization and clears local tokens
