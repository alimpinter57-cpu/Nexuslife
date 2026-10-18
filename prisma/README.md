# Phase 03 — PostgreSQL + Prisma

This folder contains the **canonical** Prisma schema used by the setup script. The script copies `prisma/schema.prisma` into the generated Next.js project so there is one schema source of truth.

## Local setup

1. Install PostgreSQL locally or create a PostgreSQL database with a trusted provider.
2. Run the setup script from this repository.
3. In the generated `nexuslife/.env`, set `DATABASE_URL` to the connection string for that database. Keep the password private; never commit `.env`.
4. From the generated project folder, run:

```bash
npx prisma validate
npx prisma generate
npx prisma migrate dev --name init
```

5. Start the app with `npm run dev`.

## Data model

- `User` and `Workspace`: ownership boundary for a user's data.
- `Habit` and `HabitLog`: habits and daily completion records.
- `WorkoutPlan`, `WorkoutSession`, `WorkoutExercise`, `ExerciseLog`, `ExerciseSet`: workout plans and session history.
- `Folder`, `Document`, `Block`, `Tag`, `DocumentTag`, `Backlink`: notes and organization.

The schema includes unique constraints for one habit log per habit/date and one workout session per plan/date. Application code must normalize dates to a consistent day boundary before writing; otherwise timestamps from the same calendar day can differ.

## Important limits

- Schema validation confirms Prisma can parse the model; it does **not** prove a database is reachable or that migrations have been applied.
- The generated app's authentication helper is still a demo placeholder. Do not deploy it or treat it as secure multi-user software until the later authentication phase replaces it and all database reads/writes enforce the authenticated user's workspace.
- GitHub Pages cannot run Prisma or connect directly to PostgreSQL. The database-backed app needs a server-capable host.
