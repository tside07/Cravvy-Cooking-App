# Week 5 — Deploy Gemini Meal Plan Edge Function

## Prerequisites

- Supabase project with `profiles`, `recipes` (seed), `meal_plans` tables
- [Supabase CLI](https://supabase.com/docs/guides/cli) installed
- Gemini API key (Google AI Studio)

## 1. Apply database migrations

In Supabase SQL Editor (or via CLI):

```bash
supabase db push
```

Or run manually:

- `supabase/migrations/20260522100000_week5_profile_cache.sql`
- `supabase/migrations/20260522100001_meal_plans_rls.sql`

## 2. Set secrets (never commit keys)

```bash
supabase secrets set GEMINI_API_KEY=your_gemini_api_key_here
# Optional if default model fails on your API key:
# supabase secrets set GEMINI_MODEL=gemini-2.0-flash
```

`SUPABASE_URL`, `SUPABASE_ANON_KEY`, and `SUPABASE_SERVICE_ROLE_KEY` are injected automatically in Edge Functions.

## 3. Link & deploy

```bash
supabase login
supabase link --project-ref <YOUR_PROJECT_REF>
supabase functions deploy generate-meal-plan
```

## 4. Test (authenticated user JWT)

```bash
curl -i --location --request POST \
  'https://<PROJECT_REF>.supabase.co/functions/v1/generate-meal-plan' \
  --header 'Authorization: Bearer <USER_ACCESS_TOKEN>' \
  --header 'Content-Type: application/json' \
  --data '{"week_start":"2026-05-19","force_refresh":false}'
```

Expected: `{ "success": true, "entries_count": 28 }` or `{ "cached": true, ... }`.

## 5. Flutter

No `GEMINI_API_KEY` in `.env` — only `SUPABASE_URL` and `SUPABASE_ANON_KEY`.

The app calls `AiMealPlanService.generateWeek()` which invokes `generate-meal-plan`. On failure, `MealSuggester` local fallback runs automatically.
