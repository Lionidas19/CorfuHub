# ch-user-app — CorfuHub Resident App

Flutter app for residents and visitors of Corfu. Provides a civic map, issue reporting, local event/job discovery, check-ins, and personalisation. All write operations are gated by phone OTP.

---

## Role

`RoleEnum.resident` — assigned automatically on first login via phone OTP.

---

## Folder Structure

```
lib/
├── main.dart                         # App entry point, DI wiring via Provider
├── features/
│   ├── map/
│   │   ├── screens/
│   │   │   ├── map_screen.dart       # Full-screen civic map (flutter_map + PostGIS)
│   │   │   ├── place_detail_screen.dart  # Place info, events, jobs, check-in CTA
│   │   │   └── search_screen.dart    # Full-text + geo search for places
│   │   └── widgets/
│   │       ├── place_marker.dart     # Custom map marker per PlaceStatus
│   │       ├── event_marker.dart     # Event pin on map
│   │       └── map_filter_bar.dart   # Status / category filter chips
│   ├── issues/
│   │   ├── screens/
│   │   │   ├── issues_map_screen.dart     # Density/cluster view of open issues
│   │   │   ├── report_issue_screen.dart   # New issue form (point + polygon draw)
│   │   │   └── issue_detail_screen.dart   # Issue thread + status timeline
│   │   └── widgets/
│   │       ├── issue_marker.dart          # Colour-coded by IssueStatus
│   │       └── polygon_draw_tool.dart     # Interactive area selection
│   ├── check_ins/
│   │   └── screens/
│   │       ├── check_in_confirm_screen.dart  # One-tap check-in confirmation
│   │       └── check_in_history_screen.dart  # Past check-ins list
│   ├── profile/
│   │   └── screens/
│   │       ├── profile_screen.dart       # Display name, home pin, saved places
│   │       ├── home_pin_screen.dart      # Set/update home location on map
│   │       └── saved_places_screen.dart  # Bookmarked places list
│   └── notifications/
│       └── screens/
│           ├── notifications_screen.dart # In-app notification feed
│           └── notification_settings_screen.dart  # Push / digest prefs
└── core/
    ├── router/
    │   └── app_router.dart            # go_router route definitions
    └── theme/
        └── app_theme.dart             # MaterialTheme, colour tokens, typography
```

---

## Screens & Routes

| Route | Screen | Description |
|---|---|---|
| `/` | `MapScreen` | Full map, place markers, filter bar |
| `/place/:id` | `PlaceDetailScreen` | Place info, events list, jobs list, check-in button |
| `/search` | `SearchScreen` | Text + geo search |
| `/issues` | `IssuesMapScreen` | Issue density map |
| `/issues/report` | `ReportIssueScreen` | New issue (point or polygon) |
| `/issues/:id` | `IssueDetailScreen` | Issue detail + status thread |
| `/check-ins/confirm` | `CheckInConfirmScreen` | One-tap confirm for current place |
| `/check-ins/history` | `CheckInHistoryScreen` | User check-in history |
| `/profile` | `ProfileScreen` | User profile + home pin + saved places |
| `/profile/home-pin` | `HomePinScreen` | Set home coordinate |
| `/profile/saved` | `SavedPlacesScreen` | Saved places list |
| `/notifications` | `NotificationsScreen` | Notification feed |
| `/notifications/settings` | `NotificationSettingsScreen` | Notification preferences |

---

## Key Features

### Civic Map
- `flutter_map` with tile provider (OpenStreetMap or Mapbox)
- Places rendered as `PlaceMarker` widgets per `PlaceStatus` (pending / active / flagged / removed)
- Events and jobs surfaced as overlay markers on a place detail popup
- Filter bar lets users narrow by category or status

### Issue Reporting
- Drop a point pin or draw a polygon area on the map
- Issue form: title, description, photo upload (future)
- Status colours: `open` (red) → `in_progress` (amber) → `resolved` (green) → `closed` (grey)

### Check-ins
- One-tap check-in from `PlaceDetailScreen` or `MapScreen` long-press
- History with timestamps; count visible on profile

### Personalisation
- Home pin stored in `user_settings` via `public.users`
- Saved places bookmarked locally and synced
- Notification prefs stored in `user_settings`

### Auth Gate
- Phone OTP only (Twilio / local stub); all write actions require authenticated session
- Unauthenticated users can browse the map read-only

---

## State Management

- `provider` package (`Provider<AppRepository>` injected at root in `main.dart`)
- Each feature uses a dedicated `ChangeNotifier` (e.g. `MapNotifier`, `IssuesNotifier`)
- Repository sourced from `corfu_shared` `AppRepositoryImpl`

---

## Environment & Run

```sh
# Local Supabase (CorfuHub.CICD)
flutter run \
  --dart-define=SUPABASE_URL=http://localhost:54331 \
  --dart-define=SUPABASE_ANON_KEY=<local-anon-key> \
  --dart-define=ENV=local \
  --dart-define=SOURCE_PROJECT=ch-user-app

# Staging
flutter run \
  --dart-define=SUPABASE_URL=https://xxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<staging-key> \
  --dart-define=ENV=staging \
  --dart-define=SOURCE_PROJECT=ch-user-app
```

---

## Dependencies

| Package | Purpose |
|---|---|
| `supabase_flutter` | Supabase client |
| `provider` | State management |
| `flutter_map` | Map rendering |
| `latlong2` | Geo coordinates |
| `go_router` | Declarative routing |
| `corfu_shared` (path) | Shared entities, models, repository, datasources |

---

## Related

- [Shared package](../shared/README.md)
- [Source of truth — Apps](../SOURCE_OF_TRUTH_APPS_MONOREPO.md)
- [CICD / Migrations](../../CICD/CorfuHub.CICD/)
