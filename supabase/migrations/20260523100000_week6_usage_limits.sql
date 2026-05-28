-- Week 6: subscription tier + weekly usage counters (swap, AI refresh)

ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS subscription_tier text NOT NULL DEFAULT 'free',
  ADD COLUMN IF NOT EXISTS premium_until timestamptz;

COMMENT ON COLUMN profiles.subscription_tier IS 'free | premium | trial';
COMMENT ON COLUMN profiles.premium_until IS 'Nullable; when set, premium/trial valid until this time';

CREATE TABLE IF NOT EXISTS user_weekly_usage (
  user_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  week_start date NOT NULL,
  swap_count int NOT NULL DEFAULT 0,
  ai_refresh_count int NOT NULL DEFAULT 0,
  updated_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, week_start)
);

ALTER TABLE user_weekly_usage ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users read own weekly usage"
  ON user_weekly_usage FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users insert own weekly usage"
  ON user_weekly_usage FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users update own weekly usage"
  ON user_weekly_usage FOR UPDATE
  USING (auth.uid() = user_id);
