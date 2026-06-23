-- AI "cook from my ingredients" feature (Search > Type tab).
--
-- Two tables:
--  1. ingredient_suggestion_cache — server-side cache keyed by the sorted
--     ingredient set + locale, so identical requests from many users cost ONE
--     Gemini call (critical on the Gemini free tier ~250 req/day for the whole
--     app). Written by the Edge Function (service role); never read by clients.
--  2. ingredient_suggestion_usage — per-user/day counter of REAL Gemini calls
--     (cache/DB hits are free and not counted) to enforce PlanLimits.

-- ── Cache ────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS ingredient_suggestion_cache (
  cache_key text PRIMARY KEY,        -- sha256(sorted ingredients + '|' + locale)
  suggestions jsonb NOT NULL,        -- array of suggestion objects (Recipe-shaped)
  created_at timestamptz NOT NULL DEFAULT now()
);

-- TTL sweeps filter on created_at.
CREATE INDEX IF NOT EXISTS ingredient_suggestion_cache_created_idx
  ON ingredient_suggestion_cache (created_at);

ALTER TABLE ingredient_suggestion_cache ENABLE ROW LEVEL SECURITY;
-- No client policies: only the Edge Function (service role) touches this table.

-- ── Per-user daily usage ──────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS ingredient_suggestion_usage (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Daily-cap counting per user.
CREATE INDEX IF NOT EXISTS ingredient_suggestion_usage_user_created_idx
  ON ingredient_suggestion_usage (user_id, created_at DESC);

ALTER TABLE ingredient_suggestion_usage ENABLE ROW LEVEL SECURITY;

-- Client may read its own usage (e.g. show remaining today); rows are inserted
-- by the Edge Function (service role) so the cap cannot be bypassed.
DROP POLICY IF EXISTS ingredient_suggestion_usage_select_own
  ON ingredient_suggestion_usage;
CREATE POLICY ingredient_suggestion_usage_select_own
  ON ingredient_suggestion_usage
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);
