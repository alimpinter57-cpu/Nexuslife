# Phase 03 — database-backed Habit API

These template files will be copied into the generated Next.js app by the setup script.

## Local development

The app does not yet include production authentication. Any temporary development identity must be explicitly enabled only in local development and must be disabled in production. Do not deploy the demo identity. The authentication phase must replace it before public deployment.

## Planned API contract

- `GET /api/habits`: list active habits and today's completion.
- `POST /api/habits`: create a habit with server-side validation.
- `PATCH /api/habits/:habitId`: update habit fields and today's completion.
- `DELETE /api/habits/:habitId`: soft-delete a habit.

All reads and writes must be scoped to the authenticated user's workspace. Completion dates must use a consistent day boundary, and the schema enforces one log per habit/date.

## Database setup

Configure a PostgreSQL `DATABASE_URL`, then run `npx prisma generate` and `npx prisma migrate dev --name init`. GitHub Pages cannot run Prisma; the database-backed app needs a server-capable host.
