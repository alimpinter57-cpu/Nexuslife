-- Add nullable Supabase Auth identity mapping without changing existing user rows.
-- Safe additive migration: existing accounts remain unlinked until explicitly linked.
ALTER TABLE public."User"
  ADD COLUMN "supabaseAuthId" TEXT;

CREATE UNIQUE INDEX "User_supabaseAuthId_key"
  ON public."User"("supabaseAuthId");
