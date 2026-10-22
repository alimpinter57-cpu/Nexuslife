-- NexusLife read-only schema and migration audit for Supabase.
-- Safe to run in Supabase SQL Editor: this script only SELECTs catalog metadata.
-- Do not run migrations or change schema until these results are reviewed.

-- 1) Confirm whether Prisma's migration ledger exists.
SELECT
  to_regclass('public._prisma_migrations') AS prisma_migrations_table,
  CASE
    WHEN to_regclass('public._prisma_migrations') IS NULL
      THEN 'NOT FOUND: do not run migrate deploy/status assumptions until investigated'
    ELSE 'FOUND: inspect migration records with the follow-up query below'
  END AS interpretation;

-- 2) Show the current public tables. Compare this list with the intended schema.
SELECT tablename
FROM pg_catalog.pg_tables
WHERE schemaname = 'public'
  AND tablename NOT LIKE 'pg_%'
ORDER BY tablename;

-- 3) Inspect key identity/workspace/habit columns without assuming every table exists.
SELECT
  table_name,
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND (
    (table_name = 'User' AND column_name IN ('id', 'email', 'supabaseAuthId', 'passwordHash', 'deletedAt'))
    OR (table_name = 'Workspace' AND column_name IN ('id', 'ownerId', 'slug', 'deletedAt'))
    OR (table_name = 'Habit' AND column_name IN ('id', 'workspaceId', 'name', 'isActive', 'deletedAt'))
    OR (table_name = 'HabitLog' AND column_name IN ('id', 'habitId', 'date', 'isCompleted'))
  )
ORDER BY table_name, ordinal_position;

-- 4) Show whether the expected migration ledger is present and whether its columns match Prisma.
-- If query 1 reports FOUND, run this read-only query:
-- SELECT migration_name, started_at, finished_at, rolled_back_at, logs
-- FROM public."_prisma_migrations"
-- ORDER BY started_at, migration_name;
-- Do not insert/update/delete ledger rows manually to make a migration appear successful.

-- 5) Inspect foreign keys for workspace ownership and habit data integrity.
SELECT
  tc.table_name,
  tc.constraint_name,
  kcu.column_name,
  ccu.table_name AS referenced_table,
  ccu.column_name AS referenced_column,
  rc.delete_rule
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
  ON tc.constraint_name = kcu.constraint_name
 AND tc.constraint_schema = kcu.constraint_schema
JOIN information_schema.constraint_column_usage ccu
  ON ccu.constraint_name = tc.constraint_name
 AND ccu.constraint_schema = tc.constraint_schema
JOIN information_schema.referential_constraints rc
  ON rc.constraint_name = tc.constraint_name
 AND rc.constraint_schema = tc.constraint_schema
WHERE tc.constraint_schema = 'public'
  AND tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_name IN ('Workspace', 'Habit', 'HabitLog')
ORDER BY tc.table_name, tc.constraint_name;

-- This script does not prove app-level authorization or RLS safety.
-- Review alongside audit-supabase-security.sql and separate two-user runtime tests.
