-- NexusLife Phase 03 security boundary.
-- The app accesses private application data through authenticated server routes
-- using Prisma. Browser clients must NOT query these tables directly.
-- This migration intentionally creates no browser-facing policies: direct
-- anon/authenticated table access stays denied until a reviewed client API exists.
-- RLS is defense in depth; it does not replace server-side workspace authorization.

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
