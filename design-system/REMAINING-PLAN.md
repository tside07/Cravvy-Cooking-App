# Kế hoạch tối ưu các màn còn lại — Soft UI Evolution (đợt 2)

> Nguồn: audit fan-out 11 nhóm module + completeness critic (2026-06-16).
> Quy ước: review sau mỗi PHẦN, như đợt 1. Mỗi phần kết thúc bằng `flutter analyze` sạch.
> Pattern lặp lại (áp dụng xuyên suốt):
> - radius `a16/a18/a20` & `BorderRadius.circular(16/20/24)` cho card/nút/sheet → `AppBorderRadius.card/button/sheet/chip` (hoặc `cardBox()`).
> - `BoxShadow` hardcode → `AppShadows.e1/e2/e3Of(brightness)` (hoặc để `cardBox()` tự lo).
> - card phẳng chỉ có border → `context.cardBox()`.
> - heading dùng `s18/s20.copyWith(fontSize lớn)` hoặc `textTheme.headlineSmall` → `AppTextStyles.h1/h2/display` (Baloo2).
> - `GestureDetector` trần trên phần tử bấm được → `Pressable`/`PressableCard`.
> - tap target <44pt (icon 30/32/36/38/40) → bọc 44pt giữ visual cũ.
> - `EdgeInsets.only/symmetric` lặp → `AppPad.*` (thêm alias khi thiếu).
> - `Animated*`/`AnimationController` → collapse khi `MediaQuery.disableAnimations`.
> - emoji làm CONTROL icon → `Icons.*` (emoji content trang trí thì giữ).
> KHÔNG đổi token brand color, KHÔNG đổi light textSecondary #6B7280 (ngoài phạm vi đã chốt).

---

## PHẦN A — Shared widgets ✅ HOÀN THÀNH — chờ review
- [x] `app_drawer.dart`: header a16→card; language chip a20→chip + bỏ emoji cờ 🇻🇳🇺🇸 (giữ Icons.language sẵn có, label VI/EN). (Drawer vốn đã theme-aware; nav label giữ Inter — không phải heading.)
- [x] `bottom_nav_bar.dart`: bỏ hardcode `fontFamily:'Inter'`→AppTextStyles.s10; 2 Animated* tôn trọng reduced-motion.
- [x] `auth_social_login_button.dart` + `auth_entry_button.dart`: a14→button token.
- [x] `auth_header_widget.dart` (shared): title s20.copyWith→h1 (Baloo2). auth_text_field đã theme-aware — không đụng.

## PHẦN B — Auth flow ✅ HOÀN THÀNH — chờ review
- [x] Heading 4 màn auth (login/register/otp/forgot) + login header_widget + reset_success: s20.copyWith→h1 (Baloo2). Giữ PreAuthTheme.textPrimary (nền hero tối cố định).
- [x] `reset_password_form_widget.dart`: icon badge circular(16)→card, button circular(16)→button, progress circular(4)→c4.
- [x] `terms_checkbox_widget.dart`: circular(4)→c4. reset SnackBar: circular(12)→card.
- [~] `otp_box_widget.dart`: GIỮ `AppColors.primaryLight` cho ô đã nhập (brand selected-state như chip, đọc tốt cả 2 theme); radius a12 đã = card.

## PHẦN C — Meal detail + Cooking mode ✅ HOÀN THÀNH — chờ review
- [x] `cooking_mode_screen.dart` (HIGH): step-count pill a20→chip; meal name→h2; progress c4; step circle shadow→e2 + số→display; step card→cardBox; timer card→card+e1; timer display→display+tabular; play/pause + reset (_TimerButton) GestureDetector→Pressable; prev/next circular(14)→button; exit dialog circular(20)→sheet. (Ảnh giữ 16 theo quy tắc card-ảnh.)
- [x] `meal_detail_header_widget.dart`: _CircleIconButton 40→44pt tap target + Pressable.
- [x] `meal_detail_servings_widget.dart`: _StepButton 36→44pt tap target + Pressable.
- [x] meal_detail tabs/instructions/nutrition: a16→card/button token. (emoji placeholder 64px & tag pill a20 trên hero: giữ.)

## PHẦN D — Settings + Account ✅
- [x] settings_card: a16→card, shadow hardcode→AppShadows.e1. nav_tile/switch_tile: a16→card, a10→chip (icon 36px là leading decoration, không phải tap target riêng → giữ). settings_screen: title→h2, dialog→sheet. premium_banner: GestureDetector→Pressable, a20→a16(feature)+e2. delete_confirm: a16→card, nút a10→button.

## PHẦN E — Search ✅
- [x] recipe_search_result_tile (HIGH): →Pressable + cardBox(16, có ảnh). type_tab (HIGH): search bar/filter circular(14)→button + Pressable, chip a12→chip + reduced-motion, 2 section title→h2. search_screen: tabbar→button/card. filter_option: circular(12)→chip + reduced-motion. filter_sheet: title→h2 + 3 sub-label→h2(15). coming_soon: headlineSmall→h2. recipe_suggestion: emoji badge a12→chip.

## PHẦN F — Premium / Subscription / Trial ✅
- [x] subscription_screen (HIGH): a16→card, shadow→e1, button circular(16)→button. plan_card: GestureDetector→Pressable, a16→card, shadow→e2, reduced-motion. premium_price_card: a16→card, price→display+tabular, AnimatedSwitcher reduced-motion. plan_toggle: →Pressable, shadow→e1, reduced-motion. premium_header title→h1. features/comparison→cardBox(). highlight_tile a14→card+e1. trial_unlocked cardBox(20)+shadow→cardBox(). trial_cta a16→button.

## PHẦN G — Onboarding ✅
- [x] landing 2 nút circular(10)→button. setup_continue circular(16)→button. setup_complete cardBox(20)→default. slide_page image circular(20)→a16 (ảnh). setup_screen: BMI card circular(16)→card + border tĩnh→borderDivider, BMI value→display+tabular, badge circular(20)→chip. (restriction input circular(12)=card-value → giữ.)

## PHẦN H — Legal + FAQ + Chat ✅
- [x] legal_section_card (HIGH): cardBox(20)+shadow hardcode→cardBox(). legal_scaffold badge circular(20)→chip. faq_screen (HIGH): chip circular(20)→chip, contact card circular(16)→card, tile cardBox(16)+shadow→cardBox(). chat_input_bar (HIGH): TextField circular(24)→sheet. (chat_bubble: giữ shape bóng chat 16/4 — ngôn ngữ bong bóng có chủ đích; padding literal giữ.)

## PHẦN I — Dashboard shell + Splash ✅
- [x] splash: GIỮ nền vàng (quyết định); tagline s18→h2; AnimationController reduced-motion (jump to end). loading_dot: Colors.white→AppColors.primary (đọc rõ trên vàng) + controller reduced-motion. (app_drawer/bottom_nav đã ở PHẦN A.)

## PHẦN J — Profile + Shopping (còn lại) ✅
- [x] edit_profile: save button a16→button + shadow→e2, danger a16→card. profile premium_banner: a18→card + Pressable + margin section16t14 + e2. field_card 14→default. language_toggle: emoji 🌐→Icons.language, cờ 🇻🇳🇺🇸→bỏ (giữ VI/EN+swap), reduced-motion, icon a10→chip, **bỏ `_labels` unused (hết warning)**. shopping_recipe_detail: cardBox(16)→default, checkbox→Pressable+44pt, stepper 30→44pt, margin→b12. shopping_list + empty_state title→h2.

---

## Quyết định đã chốt (2026-06-16):
1. **Splash background**: GIỮ nền vàng `lightYellowBackground` cả 2 mode (brand moment). Chỉ sửa dot/text để đọc được trên vàng ở cả 2 theme.
2. **Cờ ngôn ngữ** (🇻🇳/🇺🇸): THAY bằng `Icons.language` (tuân thủ triệt để không emoji-as-icon). 🌐 cũng thay.
3. **Radius card**: card NỘI DUNG (thuần text) = `card` (12); card CÓ ẢNH / feature lớn = 16.
