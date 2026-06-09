-- AI cooking assistant chat history.
-- Stores ONLY the visible conversation text. The grounding context
-- (profile snapshot, recipe shortlist, system prompt) is rebuilt per-request
-- inside the `cooking-chat` Edge Function and is never persisted here.

CREATE TABLE IF NOT EXISTS chat_messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role text NOT NULL CHECK (role IN ('user', 'assistant')),
  content text NOT NULL,
  referenced_recipe_ids uuid[] NOT NULL DEFAULT '{}',
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Fast history load + daily-cap counting per user.
CREATE INDEX IF NOT EXISTS chat_messages_user_created_idx
  ON chat_messages (user_id, created_at DESC);

ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

-- Client reads/clears its own history. INSERTs are done by the Edge Function
-- (service role) so the daily message cap cannot be bypassed.
DROP POLICY IF EXISTS chat_messages_select_own ON chat_messages;
CREATE POLICY chat_messages_select_own ON chat_messages
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS chat_messages_delete_own ON chat_messages;
CREATE POLICY chat_messages_delete_own ON chat_messages
  FOR DELETE TO authenticated
  USING (auth.uid() = user_id);
