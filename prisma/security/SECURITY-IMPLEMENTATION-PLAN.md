# NexusLife — Security implementation plan

Status: planning document only. No database settings or application code are changed by this document.

## Current verified state
- Prisma schema and the initial migration are committed on `work/blueprint-phase-03`.
- Supabase shows application tables in the `public` schema.
- The initial migration is recorded as applied.
- The current app repository root is a static `index.html` plus setup/blueprint files; a root `package.json` and a deployed server API have not been verified.
- The setup documentation explicitly says authentication is still a demo placeholder and GitHub Pages cannot host Next.js API routes/Prisma.

## Important decision before enabling RLS
Do not enable RLS and then guess policies. RLS without policies will block ordinary Data API access, while overly broad policies can expose every user's records. First identify which runtime will access the database and which identity it trusts.

## Recommended architecture
1. Keep the existing static dashboard and `main` unchanged.
2. Build the server application on a dedicated branch and deploy it to a server-capable host. GitHub Pages may remain a static preview only.
3. Prefer Supabase Auth for user identity rather than implementing password storage/session handling from scratch.
4. On the server, validate each Supabase access token with a supported server-side SDK or trusted verification method. Never trust a user ID supplied in request JSON.
5. Add an explicit mapping from the authenticated Supabase user UUID to NexusLife's internal user/workspace ownership. Review migration impact before changing the current `User.id` / `Workspace.ownerId` types.
6. Use Prisma only on the server. Never expose `DATABASE_URL`, `DIRECT_URL`, a database password, or a Supabase service-role key to browser code.
7. Implement authorization checks on every read/write: derive workspace ownership from the verified session, and scope all child records through their parent workspace. Include negative tests using two users.
8. Choose one deliberate data-access security model:
   - Preferred for a Supabase client-access model: use user JWT context and explicit RLS policies based on `auth.uid()`, after the identity mapping is implemented and tested.
   - For a Prisma-only server model: keep database credentials server-only, perform authorization in every server endpoint, and decide whether RLS should additionally be enforced with a restricted database role/session context. A privileged service-role connection bypasses RLS and must not be mistaken for RLS protection.
9. Enable RLS and apply policies only after the policy SQL has been reviewed and tested on a non-production/test project or with a rollback plan.

## Required tests before release
- Unauthenticated requests cannot read or write private data.
- User A cannot read, modify, or delete User B's workspace, habits, workout sessions, folders, documents, blocks, tags, or backlinks by changing IDs.
- Related child records cannot be accessed without ownership of the parent workspace/document/session.
- Valid owner operations succeed.
- Browser bundles/network requests contain no database password or service-role secret.
- Database migrations and RLS policies are reviewed independently; no production migration is run from an unreviewed branch.

## Immediate safe next step
Audit the actual app/API files and select the runtime/hosting architecture before writing auth endpoints or executing `prisma/security/enable-rls-baseline.sql`. The RLS baseline script is intentionally not executed.
