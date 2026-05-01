-- Promote a user to admin by email (bootstrap or one-off).
-- Prerequisites:
--   1) The person has signed up so they exist in auth.users.
--   2) A row exists in public.profiles with id = auth.users.id
--      (the app creates this on first login via getOrCreateProfile).
--
-- Run in Supabase → SQL Editor. Replace the email if needed.

UPDATE public.profiles
SET
  role = 'admin',
  updated_at = NOW()
WHERE id = (
  SELECT id
  FROM auth.users
  WHERE lower(email) = lower('mo3azrazem1@gmail.com')
);

-- Verify (optional):
-- SELECT id, email, raw_user_meta_data FROM auth.users WHERE lower(email) = lower('mo3azrazem1@gmail.com');
-- SELECT id, email, role FROM public.profiles WHERE lower(email) = lower('mo3azrazem1@gmail.com');
