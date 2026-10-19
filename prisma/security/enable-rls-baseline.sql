-- NexusLife security baseline: enable RLS on every application table.
-- Review before running. This intentionally creates NO client-access policies.
-- Result: anon/authenticated Data API requests are denied until safe policies exist.
-- A trusted server using a privileged database connection can still access data;
-- NEVER expose DATABASE_URL, DIRECT_URL, or service-role credentials in browser code.

BEGIN;

ALTER TABLE public."User" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."Workspace" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."Habit" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."HabitLog" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."MicroHabit" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."WorkoutPlan" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."WorkoutExercise" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."WorkoutSession" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."ExerciseLog" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."ExerciseSet" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."Folder" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."Document" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."Block" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."Tag" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."DocumentTag" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."Backlink" ENABLE ROW LEVEL SECURITY;

COMMIT;

-- Verify RLS is enabled:
SELECT schemaname, tablename, rowsecurity
FROM pg_catalog.pg_tables
WHERE schemaname = 'public'
  AND tablename IN (
    'User','Workspace','Habit','HabitLog','MicroHabit',
    'WorkoutPlan','WorkoutExercise','WorkoutSession','ExerciseLog',
    'ExerciseSet','Folder','Document','Block','Tag','DocumentTag','Backlink'
  )
ORDER BY tablename;
