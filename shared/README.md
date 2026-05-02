# shared

Reusable Dart/Flutter package for shared domain models, repositories, and utilities.

What MUST live in `shared/`
- Domain models: issues/reports, geometries, check-ins, places, events, jobs, claims, user settings
- Repositories / data source patterns for Supabase (table helpers, RPC wrappers, storage access patterns)
- Cross-cutting helpers: error logging client, audit event tagging (client-side metadata), encryption helpers, environment banner utilities

What MUST NOT live in `shared/`
- Supabase service-role key or any server-only secrets
- Migration SQL or schema artifacts
- Hard-coded environment URLs/keys (host apps inject these)

Supabase client injection
- Host apps must construct the Supabase client from injected env (`SUPABASE_URL`, `SUPABASE_ANON_KEY`) and pass it into `shared` APIs.

See `../SOURCE_OF_TRUTH_APPS_MONOREPO.md` for the full contract.
