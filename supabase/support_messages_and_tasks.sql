-- Run in Supabase SQL Editor (same project as lib/config/app_config.dart).
--
-- 1) tasks: date, location, description, required_skills (fixes PGRST204 missing columns)
-- 2) support_chat_messages: two-way volunteer ↔ support chat + Realtime
-- 3) RPCs: send, list threads, list messages, coordinator reply + volunteer notification
-- 4) Optional: push while app is killed — use a Database Webhook on
--    public.support_chat_messages INSERT → Edge Function → FCM/APNs (not in this file).
--
-- ── tasks columns ───────────────────────────────────────────────────────────
ALTER TABLE public.tasks
  ADD COLUMN IF NOT EXISTS date TIMESTAMPTZ;

ALTER TABLE public.tasks
  ADD COLUMN IF NOT EXISTS location TEXT;

ALTER TABLE public.tasks
  ADD COLUMN IF NOT EXISTS description TEXT;

ALTER TABLE public.tasks
  ADD COLUMN IF NOT EXISTS required_skills TEXT[];

UPDATE public.tasks
SET date = COALESCE(date, created_at, NOW())
WHERE date IS NULL;

-- ── Legacy support_messages (kept for existing installs; new traffic uses chat table)
CREATE TABLE IF NOT EXISTS public.support_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  from_user_id UUID NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  body TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  read_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_support_messages_created_at
  ON public.support_messages (created_at DESC);

ALTER TABLE public.support_messages ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "support_messages_insert_own" ON public.support_messages;
CREATE POLICY "support_messages_insert_own"
ON public.support_messages FOR INSERT TO authenticated
WITH CHECK (auth.uid() = from_user_id);

DROP POLICY IF EXISTS "support_messages_select_own" ON public.support_messages;
CREATE POLICY "support_messages_select_own"
ON public.support_messages FOR SELECT TO authenticated
USING (auth.uid() = from_user_id);

-- ── support_chat_messages (thread = one volunteer user id) ─────────────────
CREATE TABLE IF NOT EXISTS public.support_chat_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  thread_volunteer_id UUID NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  body TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_support_chat_thread_created
  ON public.support_chat_messages (thread_volunteer_id, created_at ASC);

ALTER TABLE public.support_chat_messages ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "support_chat_select_volunteer" ON public.support_chat_messages;
CREATE POLICY "support_chat_select_volunteer"
ON public.support_chat_messages FOR SELECT TO authenticated
USING (auth.uid() = thread_volunteer_id);

DROP POLICY IF EXISTS "support_chat_select_coordinator" ON public.support_chat_messages;
CREATE POLICY "support_chat_select_coordinator"
ON public.support_chat_messages FOR SELECT TO authenticated
USING (
  EXISTS (
    SELECT 1
    FROM public.profiles p
    WHERE p.id = auth.uid()
      AND lower(trim(coalesce(p.role::text, ''))) IN ('admin', 'support')
  )
);

GRANT SELECT ON public.support_chat_messages TO authenticated;

-- Realtime: enable in Dashboard → Database → Replication if INSERT events do not arrive.
DO $$
BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE public.support_chat_messages;
EXCEPTION
  WHEN duplicate_object THEN
    NULL;
END $$;

-- Copy old rows once (safe to re-run; skips obvious duplicates)
INSERT INTO public.support_chat_messages (thread_volunteer_id, sender_id, body, created_at)
SELECT sm.from_user_id, sm.from_user_id, sm.body, sm.created_at
FROM public.support_messages sm
WHERE NOT EXISTS (
  SELECT 1
  FROM public.support_chat_messages c
  WHERE c.thread_volunteer_id = sm.from_user_id
    AND c.body = sm.body
    AND c.created_at = sm.created_at
);

-- ── Volunteer sends → chat row + notify admin/support ───────────────────────
CREATE OR REPLACE FUNCTION public.submit_support_message(p_body text)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  mid uuid;
  snippet text;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'not authenticated' USING ERRCODE = '28000';
  END IF;

  IF p_body IS NULL OR length(trim(p_body)) < 1 THEN
    RAISE EXCEPTION 'message cannot be empty' USING ERRCODE = '22023';
  END IF;

  INSERT INTO public.support_chat_messages (thread_volunteer_id, sender_id, body)
  VALUES (auth.uid(), auth.uid(), trim(p_body))
  RETURNING id INTO mid;

  snippet := left(trim(p_body), 200);

  INSERT INTO public.notifications (user_id, title, body, type)
  SELECT pr.id,
         'New message from a volunteer',
         snippet,
         'support_message'
  FROM public.profiles pr
  WHERE lower(trim(coalesce(pr.role::text, ''))) IN ('admin', 'support');

  RETURN mid;
END;
$$;

REVOKE ALL ON FUNCTION public.submit_support_message(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.submit_support_message(text) TO authenticated;

-- ── Coordinator reply → chat row + notify that volunteer ───────────────────
CREATE OR REPLACE FUNCTION public.support_reply_chat(p_volunteer_id uuid, p_body text)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  mid uuid;
  snippet text;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'not authenticated' USING ERRCODE = '28000';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.profiles
    WHERE profiles.id = auth.uid()
      AND lower(trim(coalesce(profiles.role::text, ''))) IN ('admin', 'support')
  ) THEN
    RAISE EXCEPTION 'only admin or support can reply'
      USING ERRCODE = '42501';
  END IF;

  IF p_volunteer_id IS NULL THEN
    RAISE EXCEPTION 'volunteer id required' USING ERRCODE = '22023';
  END IF;

  IF p_body IS NULL OR length(trim(p_body)) < 1 THEN
    RAISE EXCEPTION 'message cannot be empty' USING ERRCODE = '22023';
  END IF;

  INSERT INTO public.support_chat_messages (thread_volunteer_id, sender_id, body)
  VALUES (p_volunteer_id, auth.uid(), trim(p_body))
  RETURNING id INTO mid;

  snippet := left(trim(p_body), 200);

  INSERT INTO public.notifications (user_id, title, body, type)
  VALUES (
    p_volunteer_id,
    'Support replied',
    snippet,
    'support_reply'
  );

  RETURN mid;
END;
$$;

REVOKE ALL ON FUNCTION public.support_reply_chat(uuid, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.support_reply_chat(uuid, text) TO authenticated;

-- ── Thread list (one row per volunteer, most recent activity first) ────────
CREATE OR REPLACE FUNCTION public.list_support_threads_for_coordinator()
RETURNS TABLE (
  thread_volunteer_id uuid,
  last_body text,
  last_at timestamptz,
  volunteer_email text,
  volunteer_name text
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM public.profiles
    WHERE profiles.id = auth.uid()
      AND lower(trim(coalesce(profiles.role::text, ''))) IN ('admin', 'support')
  ) THEN
    RAISE EXCEPTION 'only admin or support can list support threads'
      USING ERRCODE = '42501';
  END IF;

  RETURN QUERY
  WITH last_per AS (
    SELECT DISTINCT ON (m.thread_volunteer_id)
      m.thread_volunteer_id,
      m.body,
      m.created_at
    FROM public.support_chat_messages m
    ORDER BY m.thread_volunteer_id, m.created_at DESC
  )
  SELECT
    l.thread_volunteer_id,
    l.body,
    l.created_at,
    coalesce(pr.email, ''),
    coalesce(pr.full_name, '')
  FROM last_per l
  LEFT JOIN public.profiles pr ON pr.id = l.thread_volunteer_id
  ORDER BY l.created_at DESC;
END;
$$;

REVOKE ALL ON FUNCTION public.list_support_threads_for_coordinator() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.list_support_threads_for_coordinator() TO authenticated;

-- Volunteer: full thread (own)
CREATE OR REPLACE FUNCTION public.list_my_support_chat()
RETURNS TABLE (
  id uuid,
  thread_volunteer_id uuid,
  sender_id uuid,
  body text,
  created_at timestamptz
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'not authenticated' USING ERRCODE = '28000';
  END IF;

  RETURN QUERY
  SELECT
    m.id,
    m.thread_volunteer_id,
    m.sender_id,
    m.body,
    m.created_at
  FROM public.support_chat_messages m
  WHERE m.thread_volunteer_id = auth.uid()
  ORDER BY m.created_at ASC;
END;
$$;

REVOKE ALL ON FUNCTION public.list_my_support_chat() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.list_my_support_chat() TO authenticated;

-- Coordinator: full thread for one volunteer
CREATE OR REPLACE FUNCTION public.list_support_chat_thread(p_volunteer_id uuid)
RETURNS TABLE (
  id uuid,
  thread_volunteer_id uuid,
  sender_id uuid,
  body text,
  created_at timestamptz
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM public.profiles
    WHERE profiles.id = auth.uid()
      AND lower(trim(coalesce(profiles.role::text, ''))) IN ('admin', 'support')
  ) THEN
    RAISE EXCEPTION 'only admin or support can read support threads'
      USING ERRCODE = '42501';
  END IF;

  IF p_volunteer_id IS NULL THEN
    RAISE EXCEPTION 'volunteer id required' USING ERRCODE = '22023';
  END IF;

  RETURN QUERY
  SELECT
    m.id,
    m.thread_volunteer_id,
    m.sender_id,
    m.body,
    m.created_at
  FROM public.support_chat_messages m
  WHERE m.thread_volunteer_id = p_volunteer_id
  ORDER BY m.created_at ASC;
END;
$$;

REVOKE ALL ON FUNCTION public.list_support_chat_thread(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.list_support_chat_thread(uuid) TO authenticated;

-- Backwards-compatible name: same as thread list (update app to new RPC when convenient)
DROP FUNCTION IF EXISTS public.list_support_messages_for_coordinator();

CREATE OR REPLACE FUNCTION public.list_support_messages_for_coordinator()
RETURNS TABLE (
  id uuid,
  body text,
  created_at timestamptz,
  from_user_id uuid,
  sender_email text,
  sender_name text
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT
    t.thread_volunteer_id AS id,
    t.last_body AS body,
    t.last_at AS created_at,
    t.thread_volunteer_id AS from_user_id,
    t.volunteer_email AS sender_email,
    t.volunteer_name AS sender_name
  FROM public.list_support_threads_for_coordinator() AS t;
END;
$$;

REVOKE ALL ON FUNCTION public.list_support_messages_for_coordinator() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.list_support_messages_for_coordinator() TO authenticated;

NOTIFY pgrst, 'reload schema';
