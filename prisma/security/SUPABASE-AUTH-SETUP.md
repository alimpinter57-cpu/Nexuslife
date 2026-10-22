# Supabase Auth server helper setup

These files are template code, not a deployed backend. They must be copied into the generated Next.js application and tested before deployment.

## Dependencies
From the generated Next.js project directory, install:

```bash
npm install @supabase/ssr @supabase/supabase-js server-only
```

## Environment variables
Set these in the server-capable host's environment settings:
- `NEXT_PUBLIC_SUPABASE_URL`: Supabase project URL.
- `NEXT_PUBLIC_SUPABASE_ANON_KEY`: publishable/anon key only.

Keep `DATABASE_URL` and `DIRECT_URL` server-only. Never place a database URI or service-role key in any `NEXT_PUBLIC_*` variable, client component, or committed `.env` file.

## Identity linking
The API helper calls `supabase.auth.getUser()` and only resolves a NexusLife internal user where `User.supabaseAuthId` equals the verified Supabase Auth UUID. It intentionally does not auto-link by email, because email-based auto-linking can attach the wrong internal account.

A trusted account-linking flow still needs to set `supabaseAuthId` after the user proves control of both accounts, or a new-user provisioning flow needs to create the internal User and Workspace safely. Until then, authenticated Supabase users with no mapping receive 401.

## Migration caution
`0002_supabase_auth_identity/migration.sql` is additive, but it has not been applied to the live Supabase database yet. Before deployment, verify the workflow runs `prisma migrate deploy` from this branch and then run `prisma migrate status`. Do not use `prisma db push` as a substitute for reviewed migrations.

## Hosting
GitHub Pages cannot run Next.js API routes or Prisma. Deploy the generated Next.js app to a server-capable host before testing these routes. Existing static dashboard files and the `main` branch remain separate.
