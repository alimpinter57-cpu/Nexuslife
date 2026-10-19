-- Supabase Auth owns credentials; retain any existing legacy password hashes.
-- Existing rows are not deleted or rewritten by this nullable-column change.
ALTER TABLE public."User"
  ALTER COLUMN "passwordHash" DROP NOT NULL;
