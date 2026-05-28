-- Chạy toàn bộ file này trong Supabase → SQL Editor → Run
-- Sau đó: Table Editor → profiles → Refresh schema (F5)

-- ── Premium / trial ─────────────────────────────────────────────
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS subscription_tier text NOT NULL DEFAULT 'free',
  ADD COLUMN IF NOT EXISTS premium_until timestamptz;

COMMENT ON COLUMN profiles.subscription_tier IS 'free | premium | trial';
COMMENT ON COLUMN profiles.premium_until IS 'Optional expiry for premium/trial';

-- ── Đếm swap + làm mới AI theo tuần ─────────────────────────────
CREATE TABLE IF NOT EXISTS user_weekly_usage (
  user_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  week_start date NOT NULL,
  swap_count int NOT NULL DEFAULT 0,
  ai_refresh_count int NOT NULL DEFAULT 0,
  updated_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, week_start)
);

ALTER TABLE user_weekly_usage ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users read own weekly usage" ON user_weekly_usage;
CREATE POLICY "Users read own weekly usage"
  ON user_weekly_usage FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users insert own weekly usage" ON user_weekly_usage;
CREATE POLICY "Users insert own weekly usage"
  ON user_weekly_usage FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users update own weekly usage" ON user_weekly_usage;
CREATE POLICY "Users update own weekly usage"
  ON user_weekly_usage FOR UPDATE
  USING (auth.uid() = user_id);

-- ── (Tuỳ chọn) Gán Premium cho user test ─────────────────────────
-- UPDATE profiles
-- SET subscription_tier = 'premium', premium_until = NULL
-- WHERE id = 'f6e14f3c-d7bc-4dd6-8de3-469c156cca5a';

-- Kiểm tra:
-- SELECT id, email, subscription_tier, premium_until FROM profiles;
