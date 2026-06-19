# Week 5 QA Checklist

Run after deploying Edge Function (see [WEEK5_DEPLOY.md](WEEK5_DEPLOY.md)).

## Prerequisites

- [ ] Migrations applied (`meal_plan_profile_hash`, `meal_plan_week_start`, RLS)
- [ ] `GEMINI_API_KEY` set in Supabase secrets
- [ ] `generate-meal-plan` function deployed
- [ ] User logged in with completed onboarding
- [ ] `recipes` table has active rows

## AI path

- [ ] Open Meal Plan tab on empty week → loading "AI đang gợi ý thực đơn..."
- [ ] 4 meal cards per day (breakfast, lunch, dinner, snack)
- [ ] Supabase `meal_plans` has 28 rows for the week
- [ ] Tap "Làm mới" → confirm → plan regenerates (`force_refresh: true`)
- [ ] Second open same week without refresh → cache hit (no Gemini call if profile unchanged)

## Fallback path

- [ ] Temporarily break function (wrong secret) → app still shows meals via MealSuggester
- [ ] No blank error screen; user can still swap/toggle meals

## Swap / data integrity

- [ ] Swap sheet excludes current recipe by `recipe_id` (not name)
- [ ] After swap, reload app → correct recipe persists
- [ ] Home "Today's Meals" shows **today**, not week-strip selected day

## Provider

- [ ] Single `MealPlanProvider` from `main.dart` (not recreated on `/app` route)
