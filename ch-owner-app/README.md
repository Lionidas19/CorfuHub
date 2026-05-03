# ch-owner-app — CorfuHub Owner App

Flutter app for verified business owners and operators on Corfu. Covers the place-claim workflow, listing management, event and job posting, and (future) analytics. Phone OTP authentication required.

---

## Role

`RoleEnum.owner` — granted after at least one `PlaceClaim` is approved by an admin.

---

## Folder Structure

```
lib/
├── main.dart                              # App entry point, DI wiring via Provider
├── features/
│   ├── claims/
│   │   └── screens/
│   │       ├── my_claims_screen.dart          # List of owner's pending/approved claims
│   │       ├── submit_claim_screen.dart        # New claim form: select place, add evidence
│   │       └── claim_status_screen.dart        # Claim timeline: pending → approved / rejected
│   ├── listings/
│   │   ├── screens/
│   │   │   ├── my_listings_screen.dart         # Grid of owned active places
│   │   │   ├── listing_detail_screen.dart      # Full place view with owner edit controls
│   │   │   └── edit_listing_screen.dart        # Edit name, description, hours, photos
│   │   └── widgets/
│   │       ├── listing_card.dart               # Summary card for grid/list
│   │       └── listing_status_banner.dart      # Active / pending / flagged status strip
│   ├── events/
│   │   └── screens/
│   │       ├── my_events_screen.dart           # Events posted at owned places
│   │       ├── create_event_screen.dart        # New event form (title, date, place, desc)
│   │       └── event_detail_screen.dart        # Edit / cancel / view attendance
│   └── jobs/
│       └── screens/
│           ├── my_jobs_screen.dart             # Job postings at owned places
│           ├── post_job_screen.dart            # New job form (title, type, description)
│           └── job_detail_screen.dart          # Edit / close / view job enquiries
└── core/
    ├── router/
    │   └── app_router.dart                     # go_router route definitions
    └── theme/
        └── app_theme.dart                      # MaterialTheme — owner colour palette
```

---

## Screens & Routes

| Route | Screen | Description |
|---|---|---|
| `/` | `MyListingsScreen` | Grid of owned active places |
| `/listings/:id` | `ListingDetailScreen` | Place detail with owner controls |
| `/listings/:id/edit` | `EditListingScreen` | Edit place metadata |
| `/claims` | `MyClaimsScreen` | All claims by this owner |
| `/claims/submit` | `SubmitClaimScreen` | New claim form |
| `/claims/:id` | `ClaimStatusScreen` | Claim timeline + admin notes |
| `/events` | `MyEventsScreen` | Events for owned places |
| `/events/create` | `CreateEventScreen` | New event form |
| `/events/:id` | `EventDetailScreen` | Event detail + edit / cancel |
| `/jobs` | `MyJobsScreen` | Job postings for owned places |
| `/jobs/post` | `PostJobScreen` | New job posting form |
| `/jobs/:id` | `JobDetailScreen` | Job detail + edit / close |

---

## Key Features

### Claim Workflow
- Owner searches for an existing `Place` and submits a `PlaceClaim` with supporting evidence
- `claim_status`: `pending` → `approved` / `rejected` (by admin)
- Owner receives in-app notification on status change
- Approved claim unlocks full listing management for that place

### Listing Management
- Grid/list of all owned places where `claim_status = approved`
- Editable fields: name, description, category, opening hours, website, phone
- `PlaceStatus` lifecycle: `active` (default after approval) → `flagged` (admin action) → `removed`
- Flagged places show a warning banner; editing is restricted until resolved

### Event Posting
- Events linked to an owned place (`events.place_id`)
- `event_status`: `scheduled` → `active` → `completed` / `cancelled`
- Shows on the civic map for resident-app users when `event_status = active`

### Job Posting
- Jobs linked to an owned place (`jobs.place_id`)
- `job_status`: `open` → `filled` / `closed`
- Visible in resident app's place detail under the "Jobs" tab

### Auth Gate
- All create / edit / delete actions require an authenticated owner session
- Non-owner phone numbers see a CTA to submit a claim

---

## State Management

- `provider` package (`Provider<AppRepository>` injected at root in `main.dart`)
- Feature-level `ChangeNotifier` per module (e.g. `ListingsNotifier`, `ClaimsNotifier`, `EventsNotifier`, `JobsNotifier`)
- Repository sourced from `corfu_shared` `AppRepositoryImpl`

---

## Environment & Run

```sh
# Local Supabase (CorfuHub.CICD)
flutter run \
  --dart-define=SUPABASE_URL=http://localhost:54331 \
  --dart-define=SUPABASE_ANON_KEY=<local-anon-key> \
  --dart-define=ENV=local \
  --dart-define=SOURCE_PROJECT=ch-owner-app

# Staging
flutter run \
  --dart-define=SUPABASE_URL=https://xxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<staging-key> \
  --dart-define=ENV=staging \
  --dart-define=SOURCE_PROJECT=ch-owner-app
```

**Local seed owner:** phone `+306900000002`, OTP `123456`. Has one pre-approved claim for "Corfu Old Town Café".

---

## Dependencies

| Package | Purpose |
|---|---|
| `supabase_flutter` | Supabase client |
| `provider` | State management |
| `go_router` | Declarative routing |
| `corfu_shared` (path) | Shared entities, models, repository, datasources |

---

## Related

- [Shared package](../shared/README.md)
- [Source of truth — Apps](../SOURCE_OF_TRUTH_APPS_MONOREPO.md)
- [CICD / Migrations](../../CICD/CorfuHub.CICD/)
