# Tuần 4 — Checklist chuẩn bị triển khai (trước MVP Tuần 5)

**Khung thời gian:** 01/06/2026 – 07/06/2026  
**Mục tiêu:** Dữ liệu catalog ổn định, QA Tuần 5 pass, build test sẵn sàng cho **Tuần 5 / Outcome 2 Slot 5**.

Tham chiếu: [TECHNICAL_PLAN_10_WEEKS.md](TECHNICAL_PLAN_10_WEEKS.md)

---

## A. Môi trường

- [ ] Python 3.11+ cài và chạy được (`python --version` hoặc `py -3 --version`)
- [ ] `pip install -r tools/requirements.txt`
- [ ] `tools/.env` có `SUPABASE_URL` + `SUPABASE_SERVICE_ROLE_KEY` (copy từ `tools/.env.example`)
- [ ] Flutter SDK ổn định, `flutter doctor` không có lỗi blocker
- [ ] Supabase project: có quyền SQL Editor + Edge Functions deploy

---

## B. Database & migrations (cloud)

Chạy theo thứ tự (nếu chưa apply):

- [ ] Migration Tuần 5: `meal_plan_profile_hash`, `meal_plan_week_start`, RLS `meal_plans`
- [ ] Migration provenance: `recipes.source`, `source_id`, unique `(source, source_id)`
- [ ] Migration Tuần 6: `profiles.subscription_tier`, `premium_until`, bảng `user_weekly_usage`

**File nhanh:** [../supabase/RUN_IN_SQL_EDITOR_week6_premium.sql](../supabase/RUN_IN_SQL_EDITOR_week6_premium.sql)

**Verify:**

```sql
SELECT column_name FROM information_schema.columns
WHERE table_name = 'profiles' AND column_name IN ('subscription_tier', 'premium_until');

SELECT count(*) FROM recipes WHERE is_active = true;
SELECT count(*) FROM recipes WHERE source = 'cravvy_curated_vn';
```

- [ ] `recipes` active ≥ 80 (mục tiêu ≥ 100 sau import)

---

## C. Catalog VN (~100 món)

```powershell
cd E:\Project\Flutter\CravvyCookingApp\Cravvy-Cooking-App
.\tools\import_catalog.ps1
```

Hoặc thủ công:

```bash
python tools/generate_vn_seed.py
python tools/validate_seed.py
python tools/import_recipes.py --file data/seeds/vietnamese_recipes.json --dry-run
python tools/import_recipes.py --file data/seeds/vietnamese_recipes.json
```

- [x] `data/seeds/vietnamese_recipes.json` được tạo
- [x] `validate_seed.py` exit code 0
- [x] Dry-run import OK
- [x] Import thật OK (upsert `cravvy_curated_vn`)
- [x] Supabase: `SELECT count(*) FROM recipes WHERE source = 'cravvy_curated_vn'` ≥ 100

---

## D. Edge Function

- [ ] Secret `GEMINI_API_KEY` đã set trên Supabase
- [ ] Deploy `generate-meal-plan` (bản có **tier filter** Free catalog)
- [ ] POST test 200 (user JWT hợp lệ, `week_start` tuần hiện tại)
- [ ] Free user: plan chỉ dùng recipe `cravvy_curated_vn` hoặc `source IS NULL`

---

## E. QA Tuần 5 (bắt buộc trước deploy chính thức)

Làm theo [WEEK5_QA_CHECKLIST.md](WEEK5_QA_CHECKLIST.md):

- [ ] Empty week → AI loading → 4 meals/day × 7 ngày
- [ ] `meal_plans` ~28 rows/tuần
- [ ] "Làm mới" + cache hit lần 2
- [ ] Fallback khi Gemini lỗi
- [ ] Swap theo `recipe_id`, persist sau reload
- [ ] Home "Today's Meals" = hôm nay (không phụ thuộc week strip)

**Ghi chú ngày test:** _______________

---

## F. Automated tests

```bash
flutter test
```

- [x] Tất cả tests pass (visibility, usage_limit, recipe_catalog_contract, l10n, assets smoke)
- [ ] Không regression sau thay đổi Tuần 4

---

## G. Build test (internal)

```bash
flutter build apk --debug
# hoặc
flutter build apk --release
```

- [ ] APK cài được trên thiết bị thật
- [ ] Login → onboarding (nếu user mới) → Meal Plan tab load được
- [ ] Không crash khi mất mạng (fallback local)

---

## H. Học thuật (Outcome 1 Slot 4)

- [ ] Customer online survey hoàn thành
- [ ] Competitor survey (2–3 app meal plan / healthy eating)
- [ ] Tóm tắt 1 trang ảnh hưởng đến USP Tuần 5

---

## I. Sign-off Tuần 4

| Tiêu chí | Pass? |
|----------|-------|
| Catalog ≥ 100 món curated | ☐ |
| QA Tuần 5 checklist ≥ 90% tick | ☐ |
| `flutter test` green | ☐ |
| Edge Function POST 200 | ☐ |
| Test build APK OK | ☐ |

**Người ký:** _______________ **Ngày:** _______________

→ Sau sign-off: chuyển [WEEK5_STATUS.md](WEEK5_STATUS.md) và triển khai MVP Tuần 5.
