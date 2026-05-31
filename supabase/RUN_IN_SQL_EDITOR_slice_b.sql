-- Slice B: chạy toàn bộ trong Supabase → SQL Editor → Run
-- Gồm: cột ingredients (recipes) + freemium/trial + weekly usage counters
-- Sau khi chạy: Table Editor → Refresh schema (F5)

-- ── Recipes: ingredients ────────────────────────────────────────
ALTER TABLE public.recipes
  ADD COLUMN IF NOT EXISTS ingredients text[] NOT NULL DEFAULT '{}';

COMMENT ON COLUMN public.recipes.ingredients IS
  'Ingredient lines for meal detail & shopping list.';

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
  last_ai_refresh_at timestamptz,
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

-- Cooldown column (existing projects — safe to re-run)
ALTER TABLE user_weekly_usage
  ADD COLUMN IF NOT EXISTS last_ai_refresh_at timestamptz;

-- ── (Tuỳ chọn) Gán Premium cho user test ─────────────────────────
-- UPDATE profiles
-- SET subscription_tier = 'premium', premium_until = NULL
-- WHERE id = 'YOUR-USER-UUID';

-- Kiểm tra:
-- SELECT id, email, subscription_tier, premium_until FROM profiles;
-- SELECT count(*) FROM recipes WHERE source = 'cravvy_curated_vn';
