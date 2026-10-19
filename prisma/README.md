# Phase 03 — PostgreSQL + Prisma

This folder contains the canonical Prisma schema used by `setup-nexuslife.sh`. The setup script copies `prisma/schema.prisma` into the generated Next.js project so there is one schema source of truth.

## Current repository vs generated application

- The repository's root dashboard is a static GitHub Pages app. GitHub Pages cannot run Next.js API routes or Prisma.
- `templates/phase-03/` contains server-side Next.js API and Supabase Auth templates that the setup script copies into a newly generated application.
- The generated templates validate a Supabase session and resolve an internal user/workspace. This is not proof that the deployed application is configured, that database access works, or that authorization has passed multi-user tests.
- Do not deploy the generated server app until environment variables, database connectivity, authorization tests, and hosting are verified.

## Local setup — fresh disposable database only

1. Install PostgreSQL locally or create a new, empty development database.
2. Run the setup script from this repository.
3. In the generated `nexuslife/.env`, set `DATABASE_URL` and `DIRECT_URL` to the intended development database. Keep credentials private; never commit `.env`.
4. Validate and generate the Prisma client:

```bash
npx prisma validate
npx prisma generate
```

5. Only for a new, empty local development database, review the migrations and intentionally apply them:

```bash
npx prisma migrate dev
```

6. Start the app with `npm run dev`.

## Existing Supabase database — stop and inspect first

Do not run `prisma migrate dev`, `prisma migrate reset`, `prisma db push`, or SQL scripts against the existing NexusLife Supabase project just to make the app work.

Before any database change:

1. Confirm the correct Supabase project and backup/recovery options.
2. Check the actual schema and `_prisma_migrations` table using a read-only connection.
3. Compare the live schema with `prisma/schema.prisma` and each migration file.
4. Review the effect on existing records, constraints, grants, and Row Level Security.
5. Test the proposed migration and authorization policies on a separate non-production database first.

Schema validation only confirms that Prisma can parse the schema. It does not prove that the live database matches it or that a migration is safe.

## Data model

- `User` and `Workspace`: ownership boundary for a user's data.
- `Habit` and `HabitLog`: habits and daily completion records.
- `WorkoutPlan`, `WorkoutSession`, `WorkoutExercise`, `ExerciseLog`, `ExerciseSet`: workout plans and session history.
- `Folder`, `Document`, `Block`, `Tag`, `DocumentTag`, `Backlink`: notes and organization.

The schema includes unique constraints for one habit log per habit/date and one workout session per plan/date. Application code must normalize dates to a consistent day boundary before writing; otherwise timestamps for the same calendar day can differ.

## Security requirements before release

- Keep Prisma and database credentials server-side only.
- Never put `DATABASE_URL`, `DIRECT_URL`, a database password, or a Supabase service-role key in browser code.
- Derive workspace ownership from a verified server-side session; never trust a user/workspace ID supplied in request JSON.
- Test unauthenticated access and cross-workspace read/write attempts using two separate users.
- Design and test Row Level Security policies deliberately. Enabling RLS without the correct policies can block legitimate Data API access; broad policies can expose users' records.
- Do not treat a green CI build or a valid Prisma schema as proof that production authentication, database access, or RLS is safe.
