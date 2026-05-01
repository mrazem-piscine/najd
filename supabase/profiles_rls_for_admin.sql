-- Profiles RLS: coordinators (admin + support) can list all users; only admins can edit others.
-- Fixes: volunteer list empty, dashboard volunteer count 0, user management showing only yourself.
--
-- Run in Supabase → SQL Editor after public.profiles exists.

-- 1) Helpers (SECURITY DEFINER avoids RLS recursion)
CREATE OR REPLACE FUNCTION public.is_profile_admin()
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.profiles
    WHERE id = auth.uid()
      AND lower(trim(coalesce(role::text, ''))) = 'admin'
  );
$$;

CREATE OR REPLACE FUNCTION public.is_profile_coordinator()
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.profiles
    WHERE id = auth.uid()
      AND lower(trim(coalesce(role::text, ''))) IN ('admin', 'support')
  );
$$;

REVOKE ALL ON FUNCTION public.is_profile_admin() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.is_profile_coordinator() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.is_profile_admin() TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_profile_coordinator() TO authenticated;

-- 2) Reset policies on profiles
DO $$
DECLARE
  pol text;
BEGIN
  FOR pol IN
    SELECT policyname
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'profiles'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.profiles', pol);
  END LOOP;
END $$;

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "profiles_select_own_or_coordinator"
ON public.profiles
FOR SELECT
TO authenticated
USING (
  auth.uid() = id
  OR public.is_profile_coordinator()
);

CREATE POLICY "profiles_update_own"
ON public.profiles
FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

CREATE POLICY "profiles_update_admin_any"
ON public.profiles
FOR UPDATE
TO authenticated
USING (public.is_profile_admin())
WITH CHECK (public.is_profile_admin());

CREATE POLICY "profiles_insert_own"
ON public.profiles
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = id);
