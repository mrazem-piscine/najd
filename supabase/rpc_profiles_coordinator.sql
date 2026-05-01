-- RPCs bypass RLS when table policies still block coordinators/admins.
-- Run this in Supabase SQL Editor AFTER public.profiles exists.
--
-- Fixes: Volunteer tab empty, User management only shows yourself (direct .from('profiles') blocked by RLS).
--
-- IMPORTANT: Do not rely on .from('profiles').select() in the app for "all users" — RLS will hide rows.
-- The app calls these RPCs instead.

-- Admins only — use this from User management (role changes).
CREATE OR REPLACE FUNCTION public.admin_list_all_profiles()
RETURNS SETOF public.profiles
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'not authenticated' USING ERRCODE = '28000';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.profiles
    WHERE id = auth.uid()
      AND lower(trim(coalesce(role::text, ''))) = 'admin'
  ) THEN
    RAISE EXCEPTION 'only admins can list all profiles (your profiles.role must be admin)'
      USING ERRCODE = '42501';
  END IF;

  RETURN QUERY
  SELECT *
  FROM public.profiles
  ORDER BY created_at DESC NULLS LAST;
END;
$$;

REVOKE ALL ON FUNCTION public.admin_list_all_profiles() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.admin_list_all_profiles() TO authenticated;

-- Admin or support — directory / dashboard style lists.
CREATE OR REPLACE FUNCTION public.list_profiles_for_coordinator()
RETURNS SETOF public.profiles
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'not authenticated' USING ERRCODE = '28000';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.profiles
    WHERE id = auth.uid()
      AND lower(trim(coalesce(role::text, ''))) IN ('admin', 'support')
  ) THEN
    RAISE EXCEPTION 'only admin or support can list all profiles (check profiles.role for your user id)'
      USING ERRCODE = '42501';
  END IF;

  RETURN QUERY
  SELECT *
  FROM public.profiles
  ORDER BY created_at DESC NULLS LAST;
END;
$$;

REVOKE ALL ON FUNCTION public.list_profiles_for_coordinator() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.list_profiles_for_coordinator() TO authenticated;

-- Only admins may change another user's role or status (still works if RLS blocks direct UPDATE)
CREATE OR REPLACE FUNCTION public.admin_set_profile_role_and_status(
  p_user_id uuid,
  p_role text DEFAULT NULL,
  p_status text DEFAULT NULL
)
RETURNS public.profiles
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  result public.profiles;
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM public.profiles
    WHERE id = auth.uid()
      AND lower(trim(coalesce(role::text, ''))) = 'admin'
  ) THEN
    RAISE EXCEPTION 'only admins can change roles or status for other users'
      USING ERRCODE = '42501';
  END IF;

  IF p_role IS NOT NULL AND lower(trim(p_role)) NOT IN ('volunteer', 'support', 'admin') THEN
    RAISE EXCEPTION 'invalid role %', p_role USING ERRCODE = '22023';
  END IF;

  UPDATE public.profiles
  SET
    role = COALESCE(p_role, role),
    status = COALESCE(p_status, status),
    updated_at = NOW()
  WHERE id = p_user_id
  RETURNING * INTO result;

  IF result IS NULL THEN
    RAISE EXCEPTION 'profile not found for id %', p_user_id USING ERRCODE = 'P0002';
  END IF;

  RETURN result;
END;
$$;

REVOKE ALL ON FUNCTION public.admin_set_profile_role_and_status(uuid, text, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.admin_set_profile_role_and_status(uuid, text, text) TO authenticated;

-- Refresh PostgREST so the app sees new RPCs immediately (optional but helps PGRST202).
NOTIFY pgrst, 'reload schema';
