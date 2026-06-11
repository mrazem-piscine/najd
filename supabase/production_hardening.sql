-- Najd Volunteer — Production hardening (run in Supabase SQL Editor)
-- Safe to re-run. Apply after migrate_profiles_based_mvp.sql and related migrations.
--
-- Fixes:
-- 1) Block volunteers from escalating role/status on their own profile
-- 2) Tighten tasks RLS (coordinator write; volunteers read + update assigned)
-- 3) Secure ensure_support_thread RPC
-- 4) Self-service account deletion with storage cleanup

-- ─────────────────────────────────────────────────────────────────────────────
-- 1) Prevent privilege escalation on profiles
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.prevent_profile_privilege_escalation()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NOT public.is_profile_admin() THEN
    IF NEW.role IS DISTINCT FROM OLD.role THEN
      RAISE EXCEPTION 'You cannot change your own role.';
    END IF;
    IF NEW.status IS DISTINCT FROM OLD.status THEN
      RAISE EXCEPTION 'You cannot change your own account status.';
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_prevent_profile_privilege_escalation ON public.profiles;
CREATE TRIGGER trg_prevent_profile_privilege_escalation
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXEC`UTE FUNCTION public.prevent_profile_privilege_escalation();

-- ─────────────────────────────────────────────────────────────────────────────
-- 2) Tighten tasks RLS
-- ─────────────────────────────────────────────────────────────────────────────
DO $$
DECLARE
  pol text;
BEGIN
  FOR pol IN
    SELECT policyname
    FROM pg_policies
    WHERE schemaname = 'public' AND tablename = 'tasks'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.tasks', pol);
  END LOOP;
END $$;

ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;

CREATE POLICY tasks_select_authenticated
  ON public.tasks
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY tasks_insert_coordinator
  ON public.tasks
  FOR INSERT
  TO authenticated
  WITH CHECK (public.is_profile_coordinator());

CREATE POLICY tasks_update_coordinator
  ON public.tasks
  FOR UPDATE
  TO authenticated
  USING (public.is_profile_coordinator())
  WITH CHECK (public.is_profile_coordinator());

CREATE POLICY tasks_update_assigned_volunteer
  ON public.tasks
  FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.task_assignments ta
      WHERE ta.task_id = tasks.id
        AND ta.volunteer_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM public.task_assignments ta
      WHERE ta.task_id = tasks.id
        AND ta.volunteer_id = auth.uid()
    )
  );

CREATE POLICY tasks_delete_coordinator
  ON public.tasks
  FOR DELETE
  TO authenticated
  USING (public.is_profile_coordinator());

-- ─────────────────────────────────────────────────────────────────────────────
-- 3) Secure ensure_support_thread (volunteer own id or coordinator)
--    Must DROP first: existing function returns support_threads, not uuid.
-- ─────────────────────────────────────────────────────────────────────────────
DROP FUNCTION IF EXISTS public.ensure_support_thread(uuid);

CREATE OR REPLACE FUNCTION public.ensure_support_thread(p_volunteer_id uuid)
RETURNS public.support_threads
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  t public.support_threads;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  IF auth.uid() <> p_volunteer_id AND NOT public.is_profile_coordinator() THEN
    RAISE EXCEPTION 'Not allowed to open this support thread';
  END IF;

  INSERT INTO public.support_threads (volunteer_id)
  VALUES (p_volunteer_id)
  ON CONFLICT (volunteer_id) DO UPDATE
    SET updated_at = now()
  RETURNING * INTO t;

  RETURN t;
END;
$$;

REVOKE ALL ON FUNCTION public.ensure_support_thread(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.ensure_support_thread(uuid) TO authenticated;

-- ─────────────────────────────────────────────────────────────────────────────
-- 4) Self-service account deletion
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.delete_own_account()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth, storage
AS $$
DECLARE
  uid uuid := auth.uid();
BEGIN
  IF uid IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  -- Remove voice message files owned by this user
  DELETE FROM storage.objects
  WHERE bucket_id = 'voice-messages'
    AND (storage.foldername(name))[1] = uid::text;

  -- Cascades to profiles, notifications, assignments, support messages, etc.
  DELETE FROM auth.users WHERE id = uid;
END;
$$;

REVOKE ALL ON FUNCTION public.delete_own_account() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.delete_own_account() TO authenticated;

NOTIFY pgrst, 'reload schema';
