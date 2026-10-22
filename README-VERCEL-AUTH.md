# NexusLife — Vercel auth app

This branch turns the repository root into a Next.js app so Vercel can run server-side Supabase authentication and Prisma queries. The production `main` branch is unchanged.

## Required Vercel environment variables

- `NEXT_PUBLIC_APP_URL`: exact deployed app URL.
- `NEXT_PUBLIC_SUPABASE_URL`: Supabase project URL.
- `NEXT_PUBLIC_SUPABASE_ANON_KEY`: Supabase publishable/anon key; never use a service-role key here.
- `DATABASE_URL`: PostgreSQL/Supabase pooler connection for runtime.
- `DIRECT_URL`: PostgreSQL direct connection for Prisma migrations where available.

In Supabase Auth URL Configuration, add the actual Vercel app URL and callback URL `https://YOUR-DEPLOYMENT/api/auth/callback` to allowed redirect URLs.

## Database caution

The build does not run migrations. Reconcile the live database migration history and review server-only grants/RLS before running `prisma migrate deploy`. Do not run migrations from a preview build.

Routes: `/login`, `/register`, `/api/auth/callback`, `/account`, and `/api/auth/signout`.

A successful build alone does not prove runtime authentication works. Test registration, email confirmation, login, profile mapping, and logout on a preview deployment.
