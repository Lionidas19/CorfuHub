# ch-user-app

Source-of-truth (apps monorepo): this project implements the Resident (User) product surface for the Corfu Map Platform.

Key responsibilities
- Civic map: places, events, hiring postings
- Issues map: point & polygon issues, check-ins, confidence
- Personalization: home pin, saved places, notification preferences
- Privacy: phone-verified accounts; anonymous public interactions; GDPR account deletion flow

Platform contract
- Uses `../shared` for domain models and Supabase access patterns
- Loads environment via injected vars (`SUPABASE_URL`, `SUPABASE_ANON_KEY`) — never ship a service-role key
- Phone OTP gates write actions; deletes invoke server-side anonymization

See `../SOURCE_OF_TRUTH_APPS_MONOREPO.md` for full app contract and the CICD/migrations repo for schema & RLS details.
