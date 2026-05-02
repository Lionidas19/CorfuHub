# ch-owner-app

Source-of-truth (apps monorepo): this project implements the Owner product surface for the Corfu Map Platform.

Key responsibilities
- Claim / ownership workflow for places and org profiles
- Edit listing details (hours, contact, images)
- Post and manage events and job postings
- (Future) basic analytics and promotion tools

Platform contract
- Uses `../shared` for domain models and Supabase access patterns
- Loads environment via injected vars (`SUPABASE_URL`, `SUPABASE_ANON_KEY`) — never ship a service-role key
- Ownership and edit rights are enforced by the DB (claims table + RLS)

See `../SOURCE_OF_TRUTH_APPS_MONOREPO.md` for full app contract and the CICD/migrations repo for schema & RLS details.
