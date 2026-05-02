# ch-admin-app

Source-of-truth (apps monorepo): this project implements the Admin product surface for the Corfu Map Platform.

Key responsibilities
- Moderation queues (places, edits, reports)
- Dispute handling and evidence exports (PDF/CSV)
- Merges (duplicate detection/merge flows)
- Enforcement actions (warnings, bans, restricted modes)

Platform contract
- Uses `../shared` for domain models and Supabase access patterns
- Loads environment via injected vars (`SUPABASE_URL`, `SUPABASE_ANON_KEY`) — never ship a service-role key
- Admin powers are granted via DB role checks / RLS (see CICD/migrations repo for `public.is_admin()`)

See `../SOURCE_OF_TRUTH_APPS_MONOREPO.md` for full app contract and the CICD/migrations repo for schema & RLS details.
