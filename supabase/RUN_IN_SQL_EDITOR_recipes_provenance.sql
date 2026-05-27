-- Chạy TOÀN BỘ file này trong Supabase → SQL Editor → Run
-- Cần thiết trước khi: python tools/import_recipes.py ...

-- 1) Cột provenance (nếu chưa có)
ALTER TABLE recipes
  ADD COLUMN IF NOT EXISTS source text,
  ADD COLUMN IF NOT EXISTS source_id text,
  ADD COLUMN IF NOT EXISTS locale text DEFAULT 'vi';

-- 2) Unique cho upsert (PostgREST cần constraint/index khớp on_conflict)
DROP INDEX IF EXISTS recipes_source_source_id_key;

ALTER TABLE recipes DROP CONSTRAINT IF EXISTS recipes_source_source_id_key;

-- Partial unique index (có thể không đủ cho API upsert) → dùng constraint:
ALTER TABLE recipes
  ADD CONSTRAINT recipes_source_source_id_key UNIQUE (source, source_id);

-- Kiểm tra:
-- SELECT indexname FROM pg_indexes WHERE tablename = 'recipes';
-- \d recipes
