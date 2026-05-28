-- Week 5: cache AI meal plan generation per profile + week
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS meal_plan_profile_hash text,
  ADD COLUMN IF NOT EXISTS meal_plan_week_start date;

COMMENT ON COLUMN profiles.meal_plan_profile_hash IS 'SHA-256 of goal/diets/avoid_foods/anthropometrics/cooking_time';
COMMENT ON COLUMN profiles.meal_plan_week_start IS 'Monday (week start) of last AI-generated meal plan';
