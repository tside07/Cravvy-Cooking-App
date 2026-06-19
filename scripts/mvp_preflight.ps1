# MVP preflight (Slice C) — quality gate BEFORE Firebase App Distribution
# Does NOT build APK. Run: .\scripts\mvp_preflight.ps1

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot\..

Write-Host "`n=== Cravvy MVP preflight ===" -ForegroundColor Cyan

if (-not (Test-Path ".env")) {
  Write-Host "WARN: Missing root .env — copy .env.example and set SUPABASE_URL + SUPABASE_ANON_KEY" -ForegroundColor Yellow
} else {
  Write-Host "OK: .env present" -ForegroundColor Green
}

Write-Host "`n--- 1/3 Supabase catalog + schema ---" -ForegroundColor Cyan
python tools/verify_slice_b.py
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "`n--- 2/3 flutter analyze lib ---" -ForegroundColor Cyan
flutter analyze lib
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "`n--- 3/3 Core unit tests ---" -ForegroundColor Cyan
flutter test `
  test/meal_plan_visibility_test.dart `
  test/usage_limit_week_test.dart `
  test/shopping_list_provider_test.dart `
  test/recipe_ingredient_parser_test.dart `
  test/progress_week_stats_test.dart `
  test/premium_trial_test.dart `
  test/recipe_provider_featured_test.dart
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "`n=== PREFLIGHT PASSED ===" -ForegroundColor Green
Write-Host @"

Next steps (manual):
  1. Manual QA on device — see checklist below
  2. Build APK when disk space allows:
       flutter build apk --release
  3. Upload via Firebase App Distribution:
       .\scripts\firebase_distribute.ps1

--- Manual QA checklist (15 min) ---
  [ ] Register / login / onboarding complete
  [ ] Home: featured recipes, nutrition ring, today's meals
  [ ] Meal Plan: week strip, log meal, swap (Free: 3 days, swap limit)
  [ ] Explore Recipes: search, filter, sort, open detail
  [ ] Meal detail: ingredients, add to shopping list
  [ ] Shopping list: items persist after app restart
  [ ] Progress: chart + stats show real numbers
  [ ] Settings: language VI/EN, trial activation (optional)
  [ ] Known issue: AI refresh may 502 → local fallback (OK for MVP)

--- MVP feedback (ask testers) ---
  1. Dễ hiểu luồng chính không? (1-5)
  2. Meal plan có hữu ích không? (1-5)
  3. Món / công thức có phù hợp không? (1-5)
  4. Bug hoặc chỗ khó dùng nhất?
  5. Có trả tiền Premium không? Vì sao?

"@
