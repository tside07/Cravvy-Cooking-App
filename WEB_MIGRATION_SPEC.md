# Cravvy — Web Migration & Project Handoff Spec

> **Mục đích file:** Tài liệu tổng hợp một chỗ để port app Flutter **Cravvy** sang website (template [Delfood](https://themewagon.github.io/delfood/)), gửi repo, hoặc brief cho dev/AI agent.
>
> **Trạng thái app mobile:** Dừng phát triển — chuyển sang web. APK Android vẫn phân phối qua link trên landing.
>
> **Cập nhật:** 2026-06-07

---

## Mục lục

1. [Tóm tắt dự án](#1-tóm-tắt-dự-án)
2. [Trả lời brief chuyển App → Web](#2-trả-lời-brief-chuyển-app--web)
3. [Template & Tech Stack](#3-template--tech-stack)
4. [Tính năng & Routes](#4-tính-năng--routes)
5. [User Flows](#5-user-flows)
6. [Supabase Backend](#6-supabase-backend)
7. [Business Rules (Freemium)](#7-business-rules-freemium)
8. [Logic nghiệp vụ quan trọng](#8-logic-nghiệp-vụ-quan-trọng)
9. [i18n & Branding](#9-i18n--branding)
10. [Ánh xạ Delfood → Cravvy](#10-ánh-xạ-delfood--cravvy)
11. [Phase triển khai web](#11-phase-triển-khai-web)
12. [Deploy Supabase (Dashboard thủ công)](#12-deploy-supabase-dashboard-thủ-công)
13. [Files tham chiếu trong repo](#13-files-tham-chiếu-trong-repo)
14. [Acceptance criteria](#14-acceptance-criteria)
15. [Prompt khởi động cho AI/Dev](#15-prompt-khởi-động-cho-aidev)

---

## 1. Tóm tắt dự án

| Hạng mục | Chi tiết |
|----------|----------|
| **Tên** | Cravvy — AI Cooking Assistant |
| **Lĩnh vực** | Health & Fitness / Food Tech |
| **Đối tượng** | Người trẻ 18–30, bận rộn, muốn ăn lành mạnh |
| **Pain point** | Không biết hôm nay ăn gì; không muốn log calo thủ công |
| **Stack hiện tại** | Flutter · Supabase (Auth, Postgres, Edge Functions) · Gemini AI |
| **Repo** | `Cravvy-Cooking-App` (branch `dev`) |
| **Ngôn ngữ mặc định** | Tiếng Việt (`vi-VN`) |

**Core value:** Thực đơn tuần cá nhân hóa theo mục tiêu, chế độ ăn, dị ứng → công thức → cooking mode → shopping list → theo dõi dinh dưỡng + AI chat.

---

## 2. Trả lời brief chuyển App → Web

### 2.1 Mục đích app

Ứng dụng **lập kế hoạch bữa ăn thông minh có AI**, không phải TMĐT hay mạng xã hội.

### 2.2 Tính năng bắt buộc port sang web

| Tính năng | Bắt buộc | Ghi chú |
|-----------|----------|---------|
| Đăng ký / Đăng nhập (email + OAuth) | ✅ | Supabase Auth |
| Onboarding 5 bước | ✅ | Lưu `profiles` |
| AI Meal Plan 7 ngày | ✅ | Edge Function `generate-meal-plan` |
| Đổi món / Refresh AI (quota) | ✅ | |
| Thư viện công thức + search/filter | ✅ | |
| Chi tiết món + Cooking mode + timer | ✅ | |
| Shopping list (per-user sync) | ✅ | |
| AI Chat | ✅ | Edge Function `cooking-chat` |
| Progress (calo, streak, macros) | ✅ | |
| Freemium / Premium / Trial 14 ngày | ✅ UI | Chưa payment thật |
| FAQ, Privacy, Terms, Disclaimer | ✅ | |
| i18n vi-VN + en-US | ✅ | |
| Landing + Download APK Android | ✅ | Thay App Store / Google Play |
| Scan / Voice search | ❌ | Placeholder "Coming soon" |
| Push notification | ❌ phase 1 | PWA optional sau |
| Thanh toán Stripe/IAP | ❌ | Chỉ DB flag |

### 2.3 Backend

**Đã có sẵn** — web chỉ cần frontend mới kết nối Supabase project hiện tại. Không xây DB/API từ đầu.

### 2.4 Phân quyền

- **Guest:** landing, recipes public, FAQ, legal, APK
- **User đã login:** full app
- **Free / Premium / Trial:** giới hạn tính năng qua `subscription_tier` + RLS
- **Không có** admin panel

### 2.5 Responsiveness

**Mobile-first + Desktop** — không chỉ desktop.

### 2.6 Phần cứng mobile → web

| App mobile | Web |
|------------|-----|
| Camera scan | Không (coming soon) |
| Voice search | Không (coming soon) |
| GPS, Bluetooth | Không dùng |
| OAuth | Redirect URL web |
| Timer cooking | Web timer API |
| Shopping list local | `localStorage` per `userId` |

### 2.7 Thương hiệu & tùy biến template

- **Landing Delfood:** giữ layout ~40%, rebrand Cravvy
- **Dashboard / app pages:** xây mới ~90% (Delfood không có)

---

## 3. Template & Tech Stack

### Template

- **Delfood:** https://themewagon.github.io/delfood/
- Section "Get the App" → **「Tải Cravvy Android (APK)」** → `[URL_APK_CỦA_BẠN]`
- CTA phụ: **「Dùng Cravvy trên web」** → `/auth/register`

### Tech stack đề xuất (web)

| Layer | Công nghệ |
|-------|-----------|
| Frontend | Next.js 14+ (App Router) hoặc React + Vite |
| CSS | Tailwind + custom wave sections |
| Backend | Supabase (giữ project hiện tại) |
| Auth | `@supabase/supabase-js`, `@supabase/ssr` |
| AI | Gemini qua Edge Functions |
| i18n | next-intl hoặc i18next |
| Deploy | Vercel / Netlify |
| Env | `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY` |

**Không dùng** No-code (Bubble/Webflow) — logic freemium + Edge Functions quá phức tạp.

---

## 4. Tính năng & Routes

### Public

| Route | Mô tả |
|-------|-------|
| `/` | Landing (Delfood layout + Cravvy) |
| `/onboarding` | 3 slides giới thiệu |
| `/auth/login`, `/auth/register` | |
| `/auth/forgot-password`, `/auth/otp`, `/auth/reset-password` | |
| `/faq`, `/privacy-policy`, `/terms-of-service`, `/disclaimer` | |
| `/premium` | Marketing premium |

### Auth required

| Route | Mô tả |
|-------|-------|
| `/setup/1` … `/setup/5` | Onboarding questionnaire |
| `/onboarding/complete` | Tóm tắt setup |
| `/app` | Dashboard 4 tab: Home, Meal Plan, Search, Progress |
| `/recipes/all` | Catalog đầy đủ |
| `/meal-detail/:id` | Chi tiết món |
| `/cooking/:id` | Cooking mode |
| `/chat` | AI assistant |
| `/shopping-list`, `/shopping-list/recipe/:id` | Giỏ nguyên liệu |
| `/profile/edit`, `/settings` | |
| `/subscription`, `/trial-success` | |

### Route guards

- Chưa login → `/` hoặc `/auth/login`
- Login + `onboarding_complete = false` → `/setup/1`
- Login + setup xong → `/app`

---

## 5. User Flows

### Khách mới

```
Landing → Đăng ký → 3 slides → Setup 5 bước → Complete → /app → AI tạo meal plan
```

### User quay lại

```
Login → (chưa setup → Setup) → Dashboard
```

### Hàng ngày

```
Home (bữa hôm nay) → Meal Plan (sửa/đổi món) → Search → Progress
Chi tiết món → Shopping list → Cooking mode
```

### Premium

```
Upsell banner → /premium → Trial 14 ngày (DB flag)
```

---

## 6. Supabase Backend

### Bảng chính

#### `profiles`

`id` (= auth.users), `email`, `full_name`, `avatar_url`, `age`, `gender`, `height_cm`, `weight_kg`, `goal`, `diets[]`, `avoid_foods[]`, `cooking_time`, `skill_level`, `onboarding_complete`, `subscription_tier`, `premium_until`, `meal_plan_profile_hash`, `meal_plan_week_start`

#### `recipes`

`id`, `name`, `description`, `image_url`, `calories`, `protein`, `carbs`, `fat`, `prep_time`, `difficulty`, `meal_type`, `tags[]`, `steps[]`, `ingredients[]`, `source`, `source_id`, `locale`, `is_active`

#### `meal_plans`

`user_id`, `date`, `meal_type`, `recipe_id`, `is_logged` — unique `(user_id, date, meal_type)`

#### `user_weekly_usage`

`user_id`, `week_start`, `swap_count`, `ai_refresh_count`, `last_ai_refresh_at`

#### `shopping_list_items`

`id`, `user_id`, `recipe_id`, `recipe_name`, `name`, `checked`, `quantity`

#### `chat_messages`

`user_id`, `role`, `content`, `referenced_recipe_ids[]` — INSERT chỉ qua Edge Function

### Edge Functions

| Function | Mô tả | Secrets |
|----------|-------|---------|
| `generate-meal-plan` | AI meal plan 7 ngày + profile filter | `GEMINI_API_KEY` |
| `cooking-chat` | AI chat + daily cap | `GEMINI_API_KEY` |
| `delete-account` | Xóa user + data | auto-injected |

Shared: `supabase/functions/_shared/profile_recipe_filter.ts`

### RLS

- `meal_plans`, `shopping_list_items`, `user_weekly_usage`, `chat_messages`: own data only
- `recipes`: public read
- Edge Functions: service role cho writes đặc biệt

### Migrations (`supabase/migrations/`)

1. `20260522100000_week5_profile_cache.sql`
2. `20260522100001_meal_plans_rls.sql`
3. `20260522120000_recipes_provenance.sql`
4. `20260523100000_week6_usage_limits.sql`
5. `20260529100000_recipes_ingredients.sql`
6. `20260601100000_ai_refresh_cooldown.sql`
7. `20260603100000_shopping_list_items.sql`
8. `20260607100000_chat_messages.sql`

---

## 7. Business Rules (Freemium)

Nguồn: `lib/core/constants/plan_limits.dart`

| Feature | Free | Premium/Trial |
|---------|------|---------------|
| Meal plan visible days | 3 | 7 |
| Meal swaps / tuần | 2 | 5 |
| AI refresh / tuần | 1 | 2 |
| AI refresh cooldown | 5 phút | 5 phút |
| Recipe fetch limit | 100 | 500 |
| Recipe sources (free) | `cravvy_curated_vn` + null | full |
| AI chat / ngày | 15 | 60 |
| Trial | — | 14 ngày |

Premium UI (marketing, VND): Annual 999.000đ · Monthly 149.000đ — **chưa tích hợp payment**.

---

## 8. Logic nghiệp vụ quan trọng

### Onboarding setup (5 bước)

| Step | Fields |
|------|--------|
| 1 | age, gender, height_cm, weight_kg |
| 2 | goal: lose-weight, build-muscle, maintain, health |
| 3 | diets (multi): Eat Clean, Low-Carb, Keto, Vegan, ... |
| 4 | avoid_foods: allergies + No Pork, ... + custom |
| 5 | cooking_time, skill_level, onboarding_complete=true |

### NutritionCalculator

- BMR Mifflin-St Jeor → TDEE × 1.375
- lose-weight: −400 kcal; build-muscle: +300 kcal; clamp 1200–4000
- Macros % theo goal

### ProfileRecipeFilter (meal plan)

- Hard filter: avoid_foods (map "No Pork"→pork, check name+tags+ingredients), diets (Vegan, Keto, ...)
- Không fallback full catalog khi pool rỗng
- Files: `lib/core/utils/profile_recipe_filter.dart`, `supabase/functions/_shared/profile_recipe_filter.ts`

### MealSuggester (fallback local)

- 4 slots/ngày, score + deterministic pick
- `lib/core/utils/meal_suggester.dart`

### Shopping list

- Cloud: `user_id` trên mỗi row
- Local: `shopping_list_v1_<userId>` (guest: `_guest`)
- Sync: upsert, không delete-then-insert
- Serialized operations chống race condition

---

## 9. i18n & Branding

### Locales

- `assets/translations/vi-VN.json` (default)
- `assets/translations/en-US.json`

Namespaces: `nav`, `home`, `meal_plan`, `search`, `auth`, `onboarding_setup`, `chat`, `shopping_list`, `premium`, `faq`, `legal`, ...

### Brand colors (`lib/core/theme/app_colors.dart`)

| Token | Hex |
|-------|-----|
| Primary | `#FF6B35` |
| Secondary | `#2EC4B6` |
| Accent | `#FFE66D` |
| Text accent | `#6A8042` |

Font: **Inter**

Assets: `assets/images/sticket_logo.png`, `app_name.png`, `onboarding-1..3.png`

---

## 10. Ánh xạ Delfood → Cravvy

| Delfood section | Cravvy |
|-----------------|--------|
| Hero + Search | Value prop + search recipes + CTA đăng ký |
| Popular Recipes | Featured by meal_type từ Supabase |
| Get the App | **Download APK** + "Dùng web ngay" |
| About Us | Giới thiệu Cravvy |
| Latest News | Tips dinh dưỡng (placeholder) |
| Testimonial | Reviews (placeholder / i18n) |
| Footer | FAQ, Legal links |
| Login (header) | `/auth/login` |

---

## 11. Phase triển khai web

### Phase 1 — Foundation

- Clone Delfood → rebrand Cravvy
- Supabase auth + landing + popular recipes
- Section APK + FAQ/Legal

### Phase 2 — Core

- Setup 5 bước + dashboard 4 tab
- Meal plan + `generate-meal-plan`
- Recipe detail + cooking mode + search + progress

### Phase 3 — Advanced

- AI chat, shopping list sync, premium/trial, OAuth Google, EN locale

### Phase 4 — Polish

- SEO, performance, PWA optional, analytics

---

## 12. Deploy Supabase (Dashboard thủ công)

### Secrets (Project Settings → Edge Functions)

| Secret | Bắt buộc |
|--------|----------|
| `GEMINI_API_KEY` | ✅ |
| `GEMINI_MODEL` | Optional (`gemini-2.5-flash`) |

### SQL Editor (nếu chưa chạy)

```sql
-- ingredients column
ALTER TABLE public.recipes
  ADD COLUMN IF NOT EXISTS ingredients text[] NOT NULL DEFAULT '{}';
```

Chạy full file: `supabase/migrations/20260607100000_chat_messages.sql`

### Edge Functions

1. **`generate-meal-plan`:** Gộp `_shared/profile_recipe_filter.ts` vào đầu `index.ts` (Dashboard không hỗ trợ import `../_shared/`), xóa dòng import, Deploy.
2. **`cooking-chat`:** Copy `supabase/functions/cooking-chat/index.ts`, Deploy.

### Test Invoke

```json
{ "week_start": "2026-06-02", "force_refresh": true }
```

Header: `Authorization: Bearer <user_jwt>`

---

## 13. Files tham chiếu trong repo

| Mục | Path |
|-----|------|
| Routes | `lib/core/routes/app_routers.dart` |
| Plan limits | `lib/core/constants/plan_limits.dart` |
| Nutrition | `lib/core/utils/nutrition_calculator.dart` |
| Recipe filter | `lib/core/utils/profile_recipe_filter.dart` |
| Meal suggester | `lib/core/utils/meal_suggester.dart` |
| Auth | `lib/data/providers/auth_provider.dart` |
| Meal plan | `lib/modules/meal_plan/provider/meal_plan_provider.dart` |
| Chat | `lib/modules/chat/`, `lib/data/services/cooking_chat_service.dart` |
| Shopping | `lib/modules/shopping_list/` |
| i18n | `assets/translations/*.json` |
| Migrations | `supabase/migrations/*.sql` |
| Edge Functions | `supabase/functions/` |

---

## 14. Acceptance criteria

- [ ] User mới: register → setup 5 bước → meal plan personalized
- [ ] Meal plan respect goal, diets, avoid_foods
- [ ] Free: 3 ngày, quota swap/refresh/chat đúng
- [ ] Search + filter + recipe detail + cooking mode
- [ ] Shopping list per-user sync
- [ ] AI chat + daily cap
- [ ] Trial 14 ngày qua UI
- [ ] Landing APK link + vi-VN default
- [ ] Responsive mobile + desktop

---

## 15. Prompt khởi động cho AI/Dev

```
Port app Flutter Cravvy sang web dùng template Delfood (https://themewagon.github.io/delfood/).
Đọc WEB_MIGRATION_SPEC.md trong repo để biết routes, Supabase schema, freemium rules, branding.
Backend: giữ Supabase hiện tại (Edge Functions generate-meal-plan, cooking-chat).
Stack: Next.js + Tailwind + Supabase SSR.
Landing: rebrand Cravvy, section APK thay store badges.
Phase 1 trước: landing + auth + popular recipes từ Supabase.
Default locale vi-VN. Không cần payment/scan/voice phase 1.
```

---

## Phụ lục: Lệnh Git (đã dùng khi handoff)

```powershell
cd Cravvy-Cooking-App
git add -A
git reset HEAD analyze_output.txt   # bỏ file tạm nếu có
git commit -m "feat: AI chat, i18n, meal plan filters, shopping list per-user, web migration spec"
git push -u origin dev
```

Thay `origin dev` bằng branch remote của bạn nếu khác.

---

*End of WEB_MIGRATION_SPEC.md*
