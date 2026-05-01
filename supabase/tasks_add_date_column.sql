-- Align public.tasks with the Flutter app (expects column "date" for scheduled time).
-- Fixes: PostgrestException column tasks.date does not exist (42703)
--
-- Run in Supabase SQL Editor.

ALTER TABLE public.tasks
  ADD COLUMN IF NOT EXISTS date TIMESTAMPTZ;

UPDATE public.tasks
SET date = COALESCE(date, created_at)
WHERE date IS NULL;

-- Optional: enforce NOT NULL later after backfill
-- ALTER TABLE public.tasks ALTER COLUMN date SET NOT NULL;
