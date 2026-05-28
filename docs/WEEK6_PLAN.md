# Tuần 6 — Freemium & giới hạn sử dụng

## Mục tiêu

- Enforce giới hạn swap theo gói (Free 2/tuần, Premium 5/tuần).
- UI meal plan: Free **3 ngày** / Premium **7 ngày** trên week strip.
- Đồng bộ copy UI (FAQ, Subscription, Premium) với [FREEMIUM_SPEC.md](FREEMIUM_SPEC.md).
- Catalog ~100 món VN (`cravvy_curated_vn`) qua `tools/`.

## Đã làm trong repo

- [x] `plan_limits.dart`, `usage_limit_service.dart`
- [x] Migration `user_weekly_usage` + `profiles.subscription_tier`
- [x] `MealPlanProvider.swapMeal` + snackbar khi hết quota
- [x] Giới hạn “Làm mới” AI (`ai_refresh_count`)
- [x] `RecipeService` lọc `source` theo gói
- [x] UI 3 ngày (Free) + teaser khóa 4 ngày + banner upsell
- [x] Unit tests: `test/meal_plan_visibility_test.dart`, `test/usage_limit_week_test.dart`
- [x] Cập nhật `vi-VN.json` / `en-US.json`

## Việc bạn cần làm trên máy / Supabase

- [ ] Chạy migration Tuần 6 — [../supabase/RUN_IN_SQL_EDITOR_week6_premium.sql](../supabase/RUN_IN_SQL_EDITOR_week6_premium.sql) (**bắt buộc** để nút “Dùng thử 14 ngày” lưu được)
- [ ] **Test thủ công** Free: chỉ thấy 3 ô ngày + ô “+4 Mở khóa”; swap lần 3 → chặn
- [ ] **Test thủ công** Premium/trial: 7 ngày; swap đến 5/tuần
- [ ] Import catalog: `python tools/generate_vn_seed.py` → `python tools/import_recipes.py` (cần Python + env Supabase)

## Chưa làm (Tuần 6+ / sau)

- [ ] In-app purchase thật (`PremiumScreen` TODO)
- [ ] AI Nutrition Chatbot
- [x] Edge Function lọc recipe theo tier server-side (redeploy sau khi sửa)
- [x] App: `startPremiumTrial()` lưu `trial` + `premium_until` 14 ngày
- [ ] Catalog Premium 250–500+ (HF / licensed sources)

## Chạy test tự động

```bash
flutter test test/meal_plan_visibility_test.dart test/usage_limit_week_test.dart test/widget_test.dart
```

## Phụ thuộc Tuần 5

Tuần 6 **không** thay Edge Function meal plan — cần Tuần 5 QA pass. Xem [WEEK5_STATUS.md](WEEK5_STATUS.md).
