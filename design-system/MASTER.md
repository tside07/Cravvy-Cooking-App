# Cravvy Cooking App — Design System & UI/UX Plan (Master)

> Nguồn chuẩn (source of truth) cho đợt tối ưu UI/UX.
> Style direction: **Soft UI Evolution** · giữ brand cam + teal · thêm font heading.
> Trạng thái: **ĐÃ CHỐT QUYẾT ĐỊNH — chờ font assets để vào Giai đoạn 1.**

---

## 0. Quyết định đã chốt (2026-06-16)
- ✅ Duyệt cả 6 giai đoạn, **review sau mỗi giai đoạn**.
- ✅ **Font heading: Baloo 2** (rounded sans, hỗ trợ tiếng Việt đầy đủ).
  - Calistoga bị loại vì **KHÔNG có dấu tiếng Việt** → chữ có dấu sẽ vỡ font.
  - Baloo 2 = "Calistoga có tiếng Việt": bo tròn, vui, trẻ, hợp đồ ăn.
- ✅ **Nạp font: bundle `.ttf` vào `assets/fonts/`** (offline 100%, không phụ thuộc mạng).
  - Cần: `Baloo2-Regular/Medium/SemiBold/Bold.ttf` (KHÔNG dùng variable font file).
- ✅ **Token màu: chỉnh trên hệ có sẵn** (`AppColorTokens` + `AppColorExtension`), không tạo hệ mới.
- ✅ **2 hệ màu:** ưu tiên `AppColorExtension` (theme-aware qua context); `AppColors` (static const)
  thành alias, chuyển dần khi đụng widget — không refactor ồ ạt.
- ✅ **Shadow:** tạo class `AppShadows` riêng (light/dark variant) + `cardBox()`/`CardTheme` tham chiếu.
- ✅ **Ràng buộc xuyên suốt (responsive + performance):** shadow opacity thấp + const widget,
  không animate width/height (chỉ transform/opacity), `RepaintBoundary` cho card trong list,
  tôn trọng safe area + text scaling, không hardcode width cố định.

> Ghi chú phát hiện codebase: app ĐÃ có dark mode first-class (`app_theme.dart`,
> `AppColorTokens`, `AppColorExtension`). Nhiều mục Giai đoạn 1 là **chỉnh giá trị token**
> chứ không phải tạo mới. Đang tồn tại song song: `AppColors` vs `AppColorExtension` (màu),
> `AppTextStyles` vs `textTheme` (typography), `AppRadius` vs `AppBorderRadius` (radius).

---

## 1. Định hướng style: Soft UI Evolution
Chiều sâu mềm (soft 2-directional shadow), contrast tốt (WCAG AA+), dark mode mạnh,
cảm giác premium/tech nhưng vẫn ấm áp "đồ ăn". Không phải neumorphism (quá mờ), không
phải flat (không có chiều sâu).

- **Light / Dark:** cả hai là first-class, thiết kế song song.
- **Motion:** 150–300ms, ease-out khi vào / ease-in khi ra; press = scale 0.97 + shadow lift.
- **Tránh:** gray-on-gray mờ, shadow gắt, card chỉ có viền không chiều sâu, radius lung tung.

---

## 2. Color Tokens
Brand giữ nguyên. Nền chuyển từ xám lạnh → **trung tính ấm**.

| Role | Light | Dark |
|------|-------|------|
| Primary | `#FF6B35` | `#FF6B35` |
| Secondary (teal) | `#2EC4B6` | `#2EC4B6` |
| Background | `#F4F3F1` (warm gray) | `#1B1714` (warm dark) |
| Card surface | `#FFFFFF` | `#272320` |
| Elevated | `#FFFFFF` | `#2F2A26` |
| Text primary | `#1A1A2E` | `#FFFFFF` |
| Text secondary | `#6B7280` | `#C2C6CC` (nâng từ #8F959E) |
| Border / divider | `#EAE7E3` | `#37322D` |

> Giá trị dark có thể tinh chỉnh khi làm; mục tiêu: ấm + đạt contrast AA.
> **Triển khai:** chỉnh trong `AppColorTokens` / `AppColorExtension` đã tồn tại.

---

## 3. Elevation / Shadow Scale (MỚI — cốt lõi của style này)
Thêm class `AppShadows` tập trung. Mềm, opacity thấp, nhiều lớp. Có biến thể dark.

- `e1` (card nghỉ): `0 1px 2px rgba(0,0,0,.04)` + `0 2px 8px rgba(0,0,0,.05)`
- `e2` (nổi / featured / khi nhấn lift): `0 2px 4px rgba(0,0,0,.05)` + `0 8px 20px rgba(0,0,0,.07)`
- `e3` (sheet / dialog): sâu hơn, blur 24+
- Dark mode: shadow nhẹ hơn + viền sáng 1px ở mép trên thay vì chỉ dựa vào bóng.

---

## 4. Radius Scale (hợp nhất 2 hệ đang song song)
| Token | Value | Dùng cho |
|-------|-------|----------|
| sm | 8 | chip, badge, pill nhỏ |
| card | 12 | card chính (chuẩn hóa từ 16–24 xuống 12) |
| button | 14 | mọi nút (CravvyButton + ElevatedButton đồng bộ) |
| sheet | 24 | bottom sheet, container lớn |

> Giữ `AppBorderRadius`/`AppRadius` cũ làm alias để không vỡ code hiện có.

---

## 5. Spacing
Giữ thang 4/8 của `AppPad`. Thêm alias bất đối xứng để dẹp ~30 chỗ hardcode `EdgeInsets.only`.

---

## 6. Typography
- **Body:** Inter (giữ).
- **Heading:** **Baloo 2** cho tiêu đề màn & số lớn (calorie, "Hôm nay ăn gì?").
  - `AppConst.headingFont = 'Baloo2'`; thêm `AppTextStyles.display/h1/h2`.
- Weight hierarchy: heading 600–700, body 400, label 500. Số liệu dùng tabular figures.

---

## 7. Interaction (bắt buộc)
- Mọi card/nút bấm được: press feedback trong ~100ms (scale 0.97 + shadow lift, 150ms).
- Haptic light cho hành động xác nhận chính (meal swap, log, add to plan) — không phải mọi tap.
- Touch target ≥ 44pt; tôn trọng safe area.

---

# KẾ HOẠCH THỰC THI (6 giai đoạn)

> Quy ước review: **sau mỗi giai đoạn dừng lại để bạn xem** rồi mới sang bước tiếp.

## Giai đoạn 0 — Lưu design system
- [x] Tạo `design-system/MASTER.md` (file này). Không đụng code.

## Giai đoạn 1 — Tầng theme/token (nền tảng, lan tỏa toàn app) ✅ HOÀN THÀNH — chờ review
- [x] Khai báo font Baloo2 trong pubspec + thêm `AppConst.headingFont`.
- [x] Thêm `AppShadows` (e1/e2/e3, có biến thể dark).
- [x] Đổi nền sang warm neutral (sáng + tối), card tối ấm hơn — chỉnh trong token có sẵn.
- [x] Tăng contrast dark text phụ (`#8F959E → #C2C6CC`).
- [x] Hợp nhất radius: card=12, button=14, chip=8, sheet=24 (giữ alias cũ).
- [x] Nâng cấp `cardBox()`: thêm tham số `shadow` (mặc định `e1`).
- [x] Thêm `AppTextStyles.display/h1/h2` dùng Baloo2. Body giữ Inter.
- [x] Thêm AppPad alias bất đối xứng.

## Giai đoạn 2 — Component dùng chung ✅ HOÀN THÀNH — chờ review
- [x] `cravvy_button.dart`: radius 14 (`AppBorderRadius.button`) + press feedback (scale) + disabled rõ.
- [x] `custom_app_bar.dart`: nút icon 44pt + shadow e1 + press feedback.
- [x] Wrapper card có press feedback tái dùng: `Pressable` + `PressableCard` (scale + shadow lift e1→e2).
      Export qua `init.dart`. Tôn trọng reduced-motion.

## Giai đoạn 3 — Home / Meal Plan ✅ HOÀN THÀNH — chờ review
- [x] Meal card: `PressableCard` (shadow e1→e2 khi nhấn), radius 12, bỏ border hardcode (logged giữ viền success), press feedback.
- [x] Meal swap: **GIỮ sheet chọn món** (quyết định: không one-touch). Thêm haptic light khi swap thành công + animate đổi card (AnimatedSwitcher fade+scale, keyed by meal.id).
- [x] Nutrition ring / quick actions / featured recipes / today meals: heading dùng Baloo2 (`h2`), radius card chuẩn hóa 20→16.
- [x] Số calorie lớn (kcal left) dùng Baloo2 (`AppTextStyles.display`); greeting Home dùng `h1`.

## Giai đoạn 4 — Progress / Shopping / Account ✅ HOÀN THÀNH — chờ review
- [x] Stat card: shadow e1 + value Baloo2 (`h2`) + tabular figures. (Nền pastel sáng ở cả 2 theme → màu chữ cố định là đúng.)
- [x] Progress: 3 section title → Baloo2 `h2`, chart card radius 16, dẹp 4 `EdgeInsets.only` → AppPad alias.
- [x] Shopping recipe card + profile stat box: AppPad alias + tabular figures cho số liệu.

## Giai đoạn 5 — Rà soát cuối ✅ HOÀN THÀNH
- [x] **Touch ≥44pt:** meal card 2 nút action 32px → bọc tap target 44px (giữ visual 32) + press feedback. App bar icon 44px (GĐ2).
- [x] **Safe area:** không thêm full-screen surface mới; component mới là leaf widget trong scaffold sẵn có.
- [x] **Contrast AA:** đo WCAG. Dark text secondary `#C2C6CC` = 8.3–10.4 (cũ #8F959E chỉ 4.47). Nâng dark inputHint → `#9A938C` (5.14), dark disabled → `#837C75`.
      Ghi nhận: light textSecondary `#6B7280` (4.36) & các hint sát ngưỡng là token brand cũ — không tự đổi (ngoài phạm vi).
- [x] **Reduced-motion:** Pressable/PressableCard/AnimatedSwitcher đều collapse duration khi `disableAnimations`.
- [x] **Emoji:** emoji là content trang trí (món ăn, stat) — mọi control chức năng dùng `Icons.*`. Đạt.
- [x] `flutter analyze`: **0 error, 0 warning** từ code đã sửa (1 warning cũ ở language_toggle — không thuộc phạm vi).

---

## Tổng kết
6/6 giai đoạn hoàn thành. Build sạch. Soft UI Evolution + Baloo2 + dark warm neutral đã áp xuyên suốt
theme/token → component dùng chung → Home/Meal Plan → Progress/Shopping/Account.

---

## Trang có override riêng
Xem `design-system/pages/` (tạo khi cần). Ưu tiên: Home/Meal Plan, Progress, Shopping, Account.
