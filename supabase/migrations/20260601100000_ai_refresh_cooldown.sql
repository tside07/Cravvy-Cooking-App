-- Cooldown between AI meal-plan force refreshes (client + Edge Function).

ALTER TABLE user_weekly_usage
  ADD COLUMN IF NOT EXISTS last_ai_refresh_at timestamptz;

COMMENT ON COLUMN user_weekly_usage.last_ai_refresh_at IS
  'Timestamp of last force_refresh; enforces min interval between Gemini calls';
