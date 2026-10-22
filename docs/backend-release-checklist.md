# NexusLife backend release checklist

This branch is a backend-hardening preview. It is not a production release, and no database migration is run automatically.

## Required Vercel runtime variables

- `NEXT_PUBLIC_SUPABASE_URL`: Supabase project URL.
- `NEXT_PUBLIC_SUPABASE_ANON_KEY`: Supabase publishable/anon key only. This key is not a database password.
- `NEXT_PUBLIC_APP_URL`: canonical deployed app origin, for example the exact Vercel preview URL while testing. Supabase Auth must allow the callback URL `/api/auth/callback`.
- `DATABASE_URL`: PostgreSQL connection URL for the Prisma runtime. Prefer the Supabase pooler/session connection string appropriate to the deployment.

## Migration-only variable

- `DIRECT_URL`: direct PostgreSQL connection for Prisma schema validation/migrations when required. It is not used by the health endpoint. Configure it in the deployment environment used for migrations; do not substitute a fake production URL.

Never expose `DATABASE_URL`, `DIRECT_URL`, database passwords, or a Supabase service-role/secret key in `NEXT_PUBLIC_*` variables or browser code. The current app must access application tables through server-only Prisma routes. Do not grant browser roles direct table access until reviewed RLS policies and client-side access patterns exist.

## Backend checks

1. Deploy this branch as a Vercel Preview, not Production.
2. Open `/api/health`. HTTP 200 means required runtime variables are present and Prisma can execute a trivial query. HTTP 503 returns missing variable names or a generic database failure; it never returns secret values.
3. Test signup, email confirmation callback, login, and logout with a test account.
4. Open `/account`. Confirm the verified Supabase identity maps to exactly one NexusLife `User` and a personal `Workspace`.
5. Test with two distinct test accounts. Confirm no endpoint returns another user's workspace data.
6. Check Vercel runtime logs for errors, but never paste secrets or full connection URLs into logs/issues.

## Database migration safety

Do not run `prisma migrate reset`, do not use `db push` against the live database, and do not apply the RLS/grant migration blindly. Before applying any migration, compare the actual Supabase `_prisma_migrations` table and live schema with the repository migration history. A schema file alone does not prove the live database matches it. Take a backup and review the exact migration SQL first.

## Current implementation boundary

- Supabase Auth is the identity provider.
- `src/lib/auth.ts` validates the user with Supabase and resolves/provisions the internal user/workspace server-side.
- Prisma is marked server-only.
- `/api/health` provides a safe runtime readiness check.
- This is not proof that the Vercel environment, live database schema, migrations, or all application data endpoints are correct. Those require Preview runtime tests and an ownership/isolation test before release.
