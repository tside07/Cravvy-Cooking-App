-- Thay TOÀN BỘ seed cũ (~99 món demo) bằng bộ 159 món mới (đã verify nguồn + macro).
-- Chạy trong Supabase SQL Editor. An toàn / đảo ngược được (không xoá cứng).
--
-- Phân biệt 2 bộ qua source_id (cùng source='cravvy_curated_vn'):
--   * Bộ MỚI : bắt đầu bằng SỐ   -> '01_pool_bua_sang_03', '12_trua_low_carb_05', ...
--   * Bộ CŨ  : bắt đầu bằng CHỮ  -> 'pho-ga-nac', 'salad-quinoa-ga-nuong', ...

-- ── B0. (Tùy chọn) Xem trước 2 bộ trước khi đổi ──────────────────────────────
-- SELECT (source_id ~ '^[0-9]') AS la_bo_moi, count(*)
-- FROM recipes WHERE source = 'cravvy_curated_vn' GROUP BY 1;

-- ── B1. ẨN toàn bộ seed CŨ (demo, chưa có nguồn/chưa lọc an toàn) ─────────────
UPDATE public.recipes
SET is_active = false
WHERE source = 'cravvy_curated_vn'
  AND source_id !~ '^[0-9]';

-- ── B2. (Chạy SAU khi đã import 159 món mới + kiểm tra staging xong) ──────────
-- BẬT hiển thị CHỈ bộ mới:
-- UPDATE public.recipes
-- SET is_active = true
-- WHERE source = 'cravvy_curated_vn'
--   AND source_id ~ '^[0-9]';

-- ── B3. (Tùy chọn, sau khi chắc chắn) XOÁ HẲN seed cũ ────────────────────────
-- Chỉ chạy nếu không còn meal_plans/shopping_list_items nào tham chiếu (demo data):
-- DELETE FROM public.recipes
-- WHERE source = 'cravvy_curated_vn'
--   AND source_id !~ '^[0-9]';

-- ── Kiểm tra cuối ────────────────────────────────────────────────────────────
-- SELECT meal_type, count(*) FILTER (WHERE is_active) AS active
-- FROM recipes WHERE source = 'cravvy_curated_vn' GROUP BY meal_type;
