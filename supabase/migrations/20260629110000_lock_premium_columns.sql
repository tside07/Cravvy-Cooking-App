-- Khoá quyền tự-cấp Premium: client (role `authenticated`/`anon`) KHÔNG được đổi
-- subscription_tier / premium_until trên bảng profiles. Chỉ admin (SQL Editor chạy
-- dưới `postgres`) hoặc edge function (`service_role`) mới đặt được 2 cột này.
--
-- Vì sao dùng TRIGGER thay vì REVOKE/GRANT cột:
--   * Supabase mặc định GRANT ALL (table-level UPDATE) cho `authenticated`, nên
--     `REVOKE UPDATE (col) ...` ở mức cột KHÔNG có hiệu lực khi quyền table-level
--     vẫn phủ toàn bộ cột. Muốn dùng grant-cột phải REVOKE UPDATE cả bảng rồi
--     GRANT lại từng cột hợp lệ — dễ vỡ `upsert` (register/ensureProfile set
--     {id, full_name, email}) và phải liệt kê thủ công mọi cột được phép.
--   * Trigger BEFORE INSERT/UPDATE so OLD vs NEW: không đụng grant (upsert vẫn
--     chạy), không cần liệt kê cột, và chặn cả đường lách INSERT.
--
-- Phân biệt caller bằng `current_user`: PostgREST `SET LOCAL ROLE` theo JWT ->
--   - client đăng nhập  => current_user = 'authenticated'  (CHẶN)
--   - chưa đăng nhập     => current_user = 'anon'           (CHẶN; RLS cũng đã chặn)
--   - edge fn service key => current_user = 'service_role'  (CHO QUA)
--   - SQL Editor / migration => current_user = 'postgres'…  (CHO QUA)
-- Hàm KHÔNG để SECURITY DEFINER để `current_user` phản ánh đúng role gọi thật.
--
-- Áp dụng: supabase db push  (hoặc dán nguyên file vào Supabase SQL Editor).

CREATE OR REPLACE FUNCTION public.protect_profile_premium_columns()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  -- Chỉ siết đúng 2 role phía client; mọi role đặc quyền khác đi qua.
  IF current_user IN ('authenticated', 'anon') THEN
    IF TG_OP = 'INSERT' THEN
      -- Hồ sơ do client tạo phải khởi tạo ở trạng thái free, chưa có hạn premium.
      IF COALESCE(NEW.subscription_tier, 'free') <> 'free'
         OR NEW.premium_until IS NOT NULL THEN
        RAISE EXCEPTION
          'subscription_tier/premium_until chỉ admin hoặc service_role mới được đặt';
      END IF;
    ELSIF TG_OP = 'UPDATE' THEN
      IF NEW.subscription_tier IS DISTINCT FROM OLD.subscription_tier
         OR NEW.premium_until IS DISTINCT FROM OLD.premium_until THEN
        RAISE EXCEPTION
          'subscription_tier/premium_until chỉ admin hoặc service_role mới được đổi';
      END IF;
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_protect_profile_premium ON public.profiles;
CREATE TRIGGER trg_protect_profile_premium
  BEFORE INSERT OR UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.protect_profile_premium_columns();
