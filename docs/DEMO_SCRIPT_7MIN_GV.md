# Kịch bản demo 7 phút — gặp Giảng viên (Cravvy)

**Mục tiêu:** Chứng minh lõi app Tuần 3 đã chạy được; làm rõ Tuần 4–5 sẽ làm gì; tránh hứa quá (IAP thật, chatbot = phase sau).

**Thời lượng:** ~7 phút nói + thao tác (dư 1–2 phút buffer cho câu hỏi ngắn).

---

## Chuẩn bị trước khi gặp GV (15 phút)

| Việc | Ghi chú |
|------|--------|
| Build release/debug đã cài trên máy thật | Tránh emulator lag |
| Đăng nhập sẵn 1 tài khoản **đã onboarding** | Có mục tiêu, chế độ ăn, kế hoạch tuần |
| Bật Wi‑Fi / 4G ổn định | AI meal plan cần mạng |
| Tài khoản dự phòng | Nếu session hết hạn |
| Chọn ngôn ngữ | VI hoặc EN (đã có `easy_localization`) |
| Tắt thông báo máy | Tránh làm gián đoạn |

**Nếu mạng lỗi:** Nói rõ *“AI cần server Supabase; em có fallback local khi API lỗi”* — kéo refresh meal plan hoặc mở lại app.

---

## Câu mở đầu (~30 giây) — đọc gần như nguyên văn

> *“Thưa thầy/cô, em xin demo **Cravvy** — app gợi ý thực đơn và theo dõi dinh dưỡng. Em đang **cuối Tuần 3**: phần lõi đã chạy — đăng nhập, hồ sơ, **gợi ý thực đơn AI**, **đổi món**, **theo dõi calories**. **Tuần 4** em nhập kho ~100 món Việt Nam và test kỹ; **Tuần 5** mới **triển khai bản cho người dùng thử** và thu feedback theo deadline môn. **Dùng thử Premium 14 ngày** đã có giao diện; **thanh toán thật** và **chatbot dinh dưỡng** là phase sau.”*

---

## Timeline chi tiết

### Phút 0:30–1:15 — Đăng nhập & hồ sơ

| Thao tác | Nói với GV |
|----------|------------|
| Mở app → (nếu cần) **Đăng nhập** email/password | *“Xác thực qua **Supabase Auth**, dữ liệu user lưu trên cloud.”* |
| Vào tab **Hồ sơ / Profile** | *“Sau onboarding, app lưu **mục tiêu** (giảm cân, tăng cơ…), **chế độ ăn**, thời gian nấu — làm đầu vào cho AI.”* |
| Chỉ nhanh 1–2 field (goal, diet) | *“GV có thể hỏi: đổi mục tiêu → kế hoạch gợi ý lại theo profile.”* |

**Không cần** demo đăng ký mới (tốn 2 phút) trừ khi GV hỏi.

---

### Phút 1:15–3:30 — Kế hoạch ăn (trọng tâm)

| Thao tác | Nói với GV |
|----------|------------|
| Tab **Meal Plan / Kế hoạch ăn** | *“Đây là màn chính của sprint Tuần 3.”* |
| Chỉ **dải ngày trong tuần** (T2–CN) | *“Mỗi ngày 4 slot: sáng, trưa, tối, phụ. Gói **Free** xem **3 ngày**, **Premium** xem **7 ngày** — logic freemium đã có trên app.”* |
| Chọn **hôm nay** | |
| Chỉ **thẻ tổng calories + macro** (đã nạp / còn lại / mục tiêu) | *“Tự tính từ món đã ghi nhận — không nhập tay từng calo.”* |
| Tap **một món** → **Chi tiết món** | *“Xem dinh dưỡng, nguyên liệu, hướng dẫn — bước nấu chi tiết em hoàn thiện thêm Tuần 7.”* |
| Quay lại → tap icon **đổi món** (edit) trên card | *“**Đổi món** trong cùng loại bữa; Free giới hạn lần/tuần, Premium nhiều hơn — đã gắn server.”* |
| Chọn 1 món thay thế → xác nhận | *“Cập nhật lên **Supabase** `meal_plans`, không chỉ UI.”* |
| (Tuỳ chọn) Tap slot trống → **Thêm món** | *“Chọn từ catalog công thức đã sync.”* |
| Kéo xuống banner **“Làm mới gợi ý”** → mở dialog (có thể **Hủy**) | *“**AI Gemini** (Edge Function) gợi ý lại cả tuần theo profile; có giới hạn lần/tuần để kiểm soát chi phí API.”* |

**Câu kỹ thuật nếu GV hỏi:** *“Luồng: Flutter → Supabase Edge Function `generate-meal-plan` → Gemini; lỗi thì fallback gợi ý local từ catalog.”*

---

### Phút 3:30–4:30 — Đa ngôn ngữ & trải nghiệm

| Thao tác | Nói với GV |
|----------|------------|
| **Cài đặt** → đổi **Tiếng Việt / English** | *“Em dùng **easy_localization**, file `vi-VN` / `en-US` — meal plan vừa localize xong.”* |
| Quay lại Meal Plan — chỉ label đổi | *“Phục vụ demo và người dùng quốc tế sau này.”* |

---

### Phút 4:30–5:30 — Premium & gói (chỉ UI + trial)

| Thao tác | Nói với GV |
|----------|------------|
| **Profile** hoặc banner **Nâng cấp** → màn **Premium** | *“So sánh Free vs Premium: số ngày kế hoạch, lần đổi món, làm mới AI…”* |
| Chỉ nút **Dùng thử 14 ngày** (không bấm mua) | *“**Trial 14 ngày** đã có luồng kích hoạt trên backend (`premium_until`); **chưa** tích hợp **Apple/Google IAP** — đó là phase sau khi có feedback MVP.”* |
| (Nếu đang Free) chỉ banner **“Mở khóa 7 ngày”** trên meal plan | *“Upsell rõ ràng, không che khuất chức năng Free.”* |

**Tránh nói:** “Đã thanh toán được trên Store.” → Chưa.

---

### Phút 5:30–6:15 — Phạm vi đã làm / chưa làm (slide lời)

> *“**Đã xong (Tuần 3):** Auth, onboarding, meal plan AI + fallback, đổi món, calorie tracking, freemium visibility, trial UI, đa ngôn ngữ phần lõi.*
>
> ***Tuần 4:** Import ~100 món Việt (`cravvy_curated_vn`), validate data, test QA nội bộ, build APK thử.*
>
> ***Tuần 5:** Deploy production, phát hành cho user thử, thu feedback MVP — khớp Slot 5 EXE201.*
>
> ***Sau MVP:** Chatbot dinh dưỡng, IAP thật, shopping list đầy đủ, cooking mode hoàn chỉnh.”*

---

### Phút 6:15–7:00 — Kết & mời hỏi

> *“Tóm lại, em không demo bản ‘hoàn chỉnh thương mại’ mà demo **MVP lõi đúng tiến độ Tuần 3**, có lộ trình deploy Tuần 5. Em sẵn sàng nhận góp ý về **độ ưu tiên tính năng** trước khi em đóng scope Tuần 4. Thầy/cô có muốn em đi sâu phần AI, database hay freemium ạ?”*

---

## Bảng “nếu GV hỏi…”

| Câu hỏi | Trả lời ngắn |
|---------|----------------|
| AI dùng gì? | Google **Gemini** qua **Supabase Edge Function**; prompt theo profile + catalog. |
| Data ở đâu? | **Supabase** (Postgres): users, recipes, meal_plans, usage limits. |
| Free khác Premium? | Free: **3 ngày** kế hoạch, ít lần đổi món / làm mới AI; Premium: **7 ngày**, quota cao hơn. |
| Đã deploy chưa? | Backend Supabase có; **app phát hành rộng = Tuần 5** (Firebase App Distribution / APK). |
| Bảo mật? | Row Level Security Supabase; auth JWT; chưa audit đầy đủ — Tuần 9. |
| Khác app nấu ăn? | Tập trung **mục tiêu sức khỏe + thực đơn tuần AI + calo**, catalog Việt Nam. |
| Rủi ro? | Phụ thuộc API AI/chi phí; em có cache, giới hạn refresh, fallback local. |

---

## Checklist 30 giây trước khi vào phòng

- [ ] App mở được, đã login
- [ ] Meal plan có ít nhất 1 ngày có món
- [ ] Biết chỗ đổi ngôn ngữ
- [ ] Biết chỗ Premium / trial (chỉ show UI)
- [ ] Nhắc lại: **Tuần 5 = deploy + feedback**, không nhầm Tuần 10

---

## Phiên bản siêu ngắn (khi GV chỉ cho 3 phút)

1. Câu mở đầu (20s)  
2. Meal plan: tuần → calo → đổi món (2 phút)  
3. Premium trial UI + lộ trình Tuần 4–5 (40s)

---

*Tài liệu nội bộ nhóm Cravvy — cập nhật theo nhánh `feature/localization`, Tuần 3.*
