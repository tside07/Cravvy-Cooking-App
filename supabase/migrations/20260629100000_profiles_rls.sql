-- Bật Row Level Security cho bảng profiles + khoá mọi truy cập vào đúng chủ sở hữu.
-- profiles.id = auth.users.id (app query .eq('id', userId)).
--
-- Vì sao cần: bảng profiles chứa dữ liệu cá nhân (goal, diets, avoid_foods, age,
-- gender, weight_kg, height_cm, subscription_tier, premium_until...). Trước đây RLS
-- profiles KHÔNG nằm trong migration (chỉ bật qua Dashboard) -> rebuild DB là mất.
-- Migration này CODIFY trạng thái đúng + idempotent (chạy lại nhiều lần vô hại).
--
-- Áp dụng: supabase db push  (hoặc dán nguyên file vào Supabase SQL Editor).

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- SELECT: chỉ đọc được hồ sơ của chính mình.
DROP POLICY IF EXISTS profiles_select_own ON public.profiles;
CREATE POLICY profiles_select_own ON public.profiles
  FOR SELECT TO authenticated
  USING (auth.uid() = id);

-- INSERT: chỉ tạo hồ sơ cho chính mình (đường client upsert; trigger tạo profile
-- dùng service-role nên không bị RLS chặn).
DROP POLICY IF EXISTS profiles_insert_own ON public.profiles;
CREATE POLICY profiles_insert_own ON public.profiles
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = id);

-- UPDATE: chỉ sửa hồ sơ của chính mình.
DROP POLICY IF EXISTS profiles_update_own ON public.profiles;
CREATE POLICY profiles_update_own ON public.profiles
  FOR UPDATE TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- (Không mở DELETE cho client: xoá tài khoản đi qua edge function delete-account
--  bằng service-role, đã tự verify auth.uid() trước khi xoá.)
