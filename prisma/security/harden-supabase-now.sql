-- NexusLife emergency hardening for the current not-yet-connected app.
-- Run in Supabase SQL Editor only after confirming this is the NexusLife project.
-- This blocks browser-facing anon/authenticated roles from accessing app tables.
-- It is expected to block direct Supabase Data API access until reviewed policies exist.
-- It does NOT affect the server-only Prisma database connection.
-- Do NOT put DATABASE_URL / DIRECT_URL / service-role credentials in browser code.

BEGIN;

REVOKE ALL PRIVILEGES ON TABLE
  public."Backlink",
  public."Block",
  public."Document",
  public."DocumentTag",
  public."ExerciseLog",
  public."ExerciseSet",
  public."Folder",
  public."Habit",
  public."HabitLog",
  public."MicroHabit",
  public."Tag",
  public."User",
  public."Workspace",
  public."WorkoutExercise",
  public."WorkoutPlan",
  public."WorkoutSession"
FROM anon, authenticated;

ALTER TABLE public."Backlink" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."Block" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."Document" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."DocumentTag" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."ExerciseLog" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."ExerciseSet" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."Folder" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."Habit" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."HabitLog" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."MicroHabit" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."Tag" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."User" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."Workspace" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."WorkoutExercise" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."WorkoutPlan" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."WorkoutSession" ENABLE ROW LEVEL SECURITY;

COMMIT;

-- Verification 1: every app table should report rls_enabled = true.
SELECT schemaname, tablename, rowsecurity AS rls_enabled
FROM pg_catalog.pg_tables
WHERE schemaname = 'public'
  AND tablename IN (
    'Backlink','Block','Document','DocumentTag','ExerciseLog','ExerciseSet',
    'Folder','Habit','HabitLog','MicroHabit','Tag','User','Workspace',
    'WorkoutExercise','WorkoutPlan','WorkoutSession'
  )
ORDER BY tablename;

-- Verification 2: there should be no direct table grants to anon/authenticated.
SELECT table_schema, table_name, grantee, privilege_type
FROM information_schema.role_table_grants
WHERE table_schema = 'public'
  AND table_name IN (
    'Backlink','Block','Document','DocumentTag','ExerciseLog','ExerciseSet',
    'Folder','Habit','HabitLog','MicroHabit','Tag','User','Workspace',
    'WorkoutExercise','WorkoutPlan','WorkoutSession'
  )
  AND grantee IN ('anon','authenticated')
ORDER BY table_name, grantee, privilege_type;

-- Important: no RLS policies are created here. Access remains denied until
-- identity-aware policies are designed and tested. Review inherited/default
-- privileges separately if grants remain visible.
