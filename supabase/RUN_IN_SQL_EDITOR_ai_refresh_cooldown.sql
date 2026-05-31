-- Chạy 1 lần trong Supabase SQL Editor (cooldown 5 phút giữa các lần refresh AI)
ALTER TABLE user_weekly_usage
  ADD COLUMN IF NOT EXISTS last_ai_refresh_at timestamptz;

COMMENT ON COLUMN user_weekly_usage.last_ai_refresh_at IS
  'Last force_refresh timestamp; min 5 minutes between Gemini calls';
