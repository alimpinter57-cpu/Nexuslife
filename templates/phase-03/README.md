# Phase 03 — database-backed Habit API

These template files are copied into the generated Next.js app by the setup script.

## Current limitations

The repository's root dashboard is a static GitHub Pages app. GitHub Pages cannot run Next.js API routes or Prisma. These templates are backend building blocks, not proof that the full app has been generated, deployed, or security-tested.

Do not deploy the generated server app until production authentication, environment variables, database connectivity, and authorization tests have been verified.

## Planned API contract

- `GET /api/habits`: list active habits and today's completion.
- `POST /api/habits`: create a habit with server-side validation.
- `PATCH /api/habits/:habitId`: update habit fields and today's completion.
- `DELETE /api/habits/:habitId`: soft-delete a habit.

Every read and write must be scoped to the authenticated user's workspace. Never trust a user ID or workspace ID supplied by the browser. Completion dates must use a consistent day boundary, and the schema enforces one log per habit/date.

## Database setup

1. Generate the Next.js app using the repository setup script.
2. Configure both `DATABASE_URL` and `DIRECT_URL` in the generated app's local `.env`. Keep secrets private and never commit `.env`.
3. Validate the schema and generate the client:

```bash
npx prisma validate
npx prisma generate
```

4. Apply migrations only to a **new, empty disposable development database**, after reviewing the migration files. Do not run `prisma migrate dev`, `prisma migrate reset`, or `prisma db push` against the existing NexusLife Supabase database.

Before changing an existing database, inspect its live schema and `_prisma_migrations` table read-only, compare them with the schema and migrations, confirm recovery options, and test the proposed change on a separate database first.

## Before release

- Replace any temporary development identity with verified Supabase Auth.
- Keep database credentials server-side only.
- Test unauthenticated requests and cross-workspace reads/writes using two separate test users.
- Design and test Row Level Security policies deliberately. Enabling RLS without suitable policies can block legitimate access; broad policies can expose user data.
- A successful CI build or schema validation alone does not prove production authentication, database connectivity, or data isolation is safe.
