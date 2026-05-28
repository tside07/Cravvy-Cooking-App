# Tuần 5 — Trạng thái chốt

## Kết luận

**Tuần 5 về mặt code/infrastructure: coi như đã chốt** sau khi bạn xác nhận checklist QA trên thiết bị thật.

| Hạng mục | Trạng thái |
|----------|------------|
| Edge Function `generate-meal-plan` + Gemini | ✅ Đã deploy (POST 200, cache đã test) |
| Migration profile hash + RLS `meal_plans` | ✅ Có trong repo — cần `db push` trên project |
| `AiMealPlanService` + fallback `MealSuggester` | ✅ |
| `MealPlanProvider` single instance, swap `recipe_id`, `todayDay` | ✅ |
| QA checklist đầy đủ | ⏳ **Bạn tick** trên [WEEK5_QA_CHECKLIST.md](WEEK5_QA_CHECKLIST.md) |

## Chưa thuộc Tuần 5 (chuyển Tuần 6+)

- Giới hạn Free vs Premium (swap, AI refresh) — **Tuần 6**
- Import catalog 100+ món — song song với dataset
- Thanh toán in-app thật — sau

## Việc bạn cần làm để “chốt hẳn” Tuần 5

1. Chạy hết [WEEK5_QA_CHECKLIST.md](WEEK5_QA_CHECKLIST.md) trên app đang `flutter run`.
2. Tick các ô trong file checklist (hoặc ghi “đã test ngày …” vào cuối file).
3. Đảm bảo `recipes` có dữ liệu (`SELECT count(*) FROM recipes WHERE is_active`).

Sau 3 bước trên → **Tuần 5 closed**; tiếp tục [WEEK6_PLAN.md](WEEK6_PLAN.md).
