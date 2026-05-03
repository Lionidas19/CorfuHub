# ch-admin-app — CorfuHub Admin App

Flutter app for CorfuHub platform administrators. Provides moderation queues, dispute resolution, place-merge tooling, enforcement actions, and KPI dashboards. Phone OTP authentication required.

---

## Role

`RoleEnum.admin` — must be manually assigned in `public.users` by a super-admin or seed SQL.

---

## Folder Structure

```
lib/
├── main.dart                              # App entry point, DI wiring via Provider
├── features/
│   ├── moderation/
│   │   ├── screens/
│   │   │   ├── moderation_dashboard_screen.dart  # Queue overview: claims, issues, flags
│   │   │   ├── place_review_screen.dart           # Review a pending/flagged Place
│   │   │   └── claim_review_screen.dart           # Approve / reject PlaceClaim
│   │   └── widgets/
│   │       ├── moderation_queue_tile.dart         # Summary tile for queue items
│   │       └── status_badge.dart                  # Colour-coded status chip
│   ├── disputes/
│   │   └── screens/
│   │       ├── disputes_list_screen.dart          # Open dispute feed
│   │       └── dispute_detail_screen.dart         # Evidence, timeline, resolution form
│   ├── enforcement/
│   │   └── screens/
│   │       ├── enforcement_screen.dart            # Issue escalation + admin actions
│   │       └── flag_history_screen.dart           # Flagged content log
│   ├── merges/
│   │   └── screens/
│   │       ├── merge_candidates_screen.dart       # Duplicate place candidates list
│   │       └── merge_review_screen.dart           # Side-by-side merge diff + confirm
│   └── analytics/
│       └── screens/
│           ├── kpi_dashboard_screen.dart          # Platform KPIs (places, issues, users)
│           └── audit_log_screen.dart              # Browse audit_log table
└── core/
    ├── router/
    │   └── app_router.dart                        # go_router route definitions
    └── theme/
        └── app_theme.dart                         # MaterialTheme — admin colour palette
```

---

## Screens & Routes

| Route | Screen | Description |
|---|---|---|
| `/` | `ModerationDashboardScreen` | Queue overview with item counts |
| `/moderation/place/:id` | `PlaceReviewScreen` | Full place detail + approve/flag/remove actions |
| `/moderation/claim/:id` | `ClaimReviewScreen` | Claim evidence + approve/reject |
| `/disputes` | `DisputesListScreen` | Open disputes feed |
| `/disputes/:id` | `DisputeDetailScreen` | Evidence thread + resolution form |
| `/enforcement` | `EnforcementScreen` | Escalation queue + force-resolve issues |
| `/enforcement/flags` | `FlagHistoryScreen` | Full flagged-content log |
| `/merges` | `MergeCandidatesScreen` | Detected duplicate place pairs |
| `/merges/:id` | `MergeReviewScreen` | Side-by-side diff, select canonical record, confirm merge |
| `/analytics` | `KpiDashboardScreen` | Charts: active places, open issues, MAU, check-ins |
| `/analytics/audit` | `AuditLogScreen` | Paginated `audit_log` browse with filters |

---

## Key Features

### Moderation Queue
- Aggregated view of pending `PlaceClaims` (claim_status = `pending`), flagged `Places`, and escalated `Issues`
- One-tap approve / reject / flag actions with optional admin comment
- All actions written via `AppRepository` → `SupabaseDataSource`; every change is captured by the `audit_trigger`

### Dispute Resolution
- Disputes surface when an owner contests an admin decision
- Admin reviews evidence attachments, owner notes, and prior audit trail
- Resolution options: uphold, reverse, escalate

### Place Merges
- Duplicate detection candidates surfaced from a backend view (future: similarity score)
- Admin selects canonical record; merge writes through to all FK references before archiving duplicate

### Enforcement
- Force-resolve or escalate open `Issues` to external authorities
- Soft-delete or permanently remove `Places` or `PlaceClaims` with reason logging
- All enforcement actions timestamped in `audit_log`

### KPI Dashboard
- Charts rendered from Supabase RPC / view queries
- Key metrics: active place count, open vs resolved issue ratio, daily check-ins, new user signups
- Audit log browser with table/status/actor filters

---

## State Management

- `provider` package (`Provider<AppRepository>` injected at root in `main.dart`)
- Feature-level `ChangeNotifier` per module (e.g. `ModerationNotifier`, `DisputeNotifier`)
- Repository sourced from `corfu_shared` `AppRepositoryImpl`

---

## Environment & Run

```sh
# Local Supabase (CorfuHub.CICD)
flutter run \
  --dart-define=SUPABASE_URL=http://localhost:54331 \
  --dart-define=SUPABASE_ANON_KEY=<local-anon-key> \
  --dart-define=ENV=local \
  --dart-define=SOURCE_PROJECT=ch-admin-app

# Staging
flutter run \
  --dart-define=SUPABASE_URL=https://xxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<staging-key> \
  --dart-define=ENV=staging \
  --dart-define=SOURCE_PROJECT=ch-admin-app
```

**Note:** Admin role must be seeded or manually assigned. Use seed.sql admin user (`+306900000003`) for local development.

---

## Dependencies

| Package | Purpose |
|---|---|
| `supabase_flutter` | Supabase client |
| `provider` | State management |
| `go_router` | Declarative routing |
| `fl_chart` | KPI charts |
| `corfu_shared` (path) | Shared entities, models, repository, datasources |

---

## Related

- [Shared package](../shared/README.md)
- [Source of truth — Apps](../SOURCE_OF_TRUTH_APPS_MONOREPO.md)
- [CICD / Migrations](../../CICD/CorfuHub.CICD/)
