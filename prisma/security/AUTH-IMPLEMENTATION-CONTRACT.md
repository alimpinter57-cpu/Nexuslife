# NexusLife Auth Phase — implementation contract

This file is a technical checklist for the next implementation commit. It does not claim authentication is already implemented.

## Chosen direction
Use Supabase Auth as the identity provider. Keep Prisma and DATABASE_URL/DIRECT_URL server-only. Do not implement password storage in the NexusLife User table until the identity mapping has been deliberately designed.

## Required server helper behavior
- Create a server-only Supabase client using `@supabase/ssr` and Next.js `cookies()`.
- Call `supabase.auth.getUser()` on the server to validate the current user; do not trust a decoded JWT or a user ID sent in request JSON.
- If there is no valid Supabase user, return unauthenticated and fail closed.
- Map the validated Supabase Auth UUID to an internal NexusLife User using an explicit unique column such as `supabaseAuthId`. Add that column through a reviewed Prisma migration; do not assume Supabase UUIDs match existing Prisma-generated IDs.
- Find the user's Workspace by `ownerId = internalUser.id`. If none exists, create the default workspace only inside a transaction and use a collision-safe slug.
- Every API operation must scope queries by the workspace derived from the validated session. Never accept a client-supplied workspaceId as authorization.
- Use generic error responses. Do not log tokens, cookies, password values, or connection strings.

## Required dependencies and environment
- Add `@supabase/ssr` and `@supabase/supabase-js` to the generated Next.js project's dependencies.
- Configure server environment variables `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY` (the anon key is public by design; RLS must remain enabled).
- Keep `DATABASE_URL`, `DIRECT_URL`, and any service-role key server-only. Never prefix secrets with `NEXT_PUBLIC_`.
- Configure Supabase Auth site URL and allowed redirect URLs for the actual deployed app.

## Test gate before enabling production auth
1. Signed-out request to GET /api/habits returns 401.
2. Signed-in user with mapped account can only see own workspace habits.
3. User A cannot read/update User B's habit by guessing its ID.
4. Invalid/expired session returns 401.
5. No password, token, database URI, or service-role key appears in browser bundle or logs.
6. Existing static dashboard remains unchanged; backend is deployed to a server-capable host, not GitHub Pages.

## RLS note
The emergency hardening step removed direct table grants from anon/authenticated and enabled RLS without policies. This intentionally blocks direct Data API table access. The Prisma server connection may still work, depending on its database role. Do not add permissive policies or restore broad grants just to make the UI work.
