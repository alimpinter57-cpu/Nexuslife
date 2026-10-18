# Supabase + Prisma — Nexuslife

This file documents the next database setup step. It does not contain credentials.

## 1. Create a Supabase project
1. Create a project in the Supabase dashboard and keep the database password private.
2. In **Project Settings → Database**, obtain the connection strings.
3. Use the **pooler connection** for the running application when recommended by Supabase; use the **direct connection** for Prisma CLI migrations if your network/provider supports it.

## 2. Configure the generated Next.js project
Create or edit `.env` in the generated `nexuslife/` folder (never commit this file):

```dotenv
# Runtime connection (Supabase pooler, if using pooled connections)
DATABASE_URL="postgresql://USER:PASSWORD@HOST:6543/postgres?pgbouncer=true"

# Direct connection for Prisma migrations; use the exact URI Supabase provides
DIRECT_URL="postgresql://USER:PASSWORD@HOST:5432/postgres"
```

These are illustrative shapes only. Replace them with the exact connection strings from your own Supabase project; do not copy the example hosts or ports blindly.

## 3. Prisma schema configuration
The schema currently uses `DATABASE_URL` as its datasource. Before relying on `DIRECT_URL`, add `directUrl = env("DIRECT_URL")` to the Prisma datasource block, and ensure both variables exist in the local environment. Keep this change in sync with the canonical schema at `prisma/schema.prisma` and the schema embedded/copied by `setup-nexuslife.sh`.

Then, inside the generated project:

```bash
npx prisma validate
npx prisma generate
npx prisma migrate dev --name init
```

Review the migration before applying it. Do not run migrations against a database containing important data without a backup.

## Security and deployment
- Never commit `.env`, database passwords, or Supabase service-role keys.
- The database URL is server-only. Do not prefix it with `NEXT_PUBLIC_`.
- Do not expose a service-role key in browser code.
- A real authenticated-user boundary and workspace ownership checks are required before using this as a multi-user production app.
- GitHub Pages cannot run Next.js API routes or Prisma. Deploy the server-capable app separately.
- Schema validation is not a live database connection test; a successful migration is a separate verification step.
